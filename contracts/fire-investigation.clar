;; Fire Investigation Management Contract
;; Manages fire incident investigations and case tracking

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u200))
(define-constant ERR-INVALID-INPUT (err u201))
(define-constant ERR-CASE-NOT-FOUND (err u202))
(define-constant ERR-ALREADY-EXISTS (err u203))
(define-constant ERR-INVALID-STATUS (err u204))

;; Data Variables
(define-data-var next-case-id uint u1)

;; Data Maps
(define-map investigation-cases
  { case-id: uint }
  {
    incident-location: (string-ascii 200),
    incident-type: (string-ascii 50),
    report-date: uint,
    reporter: principal,
    assigned-investigator: (optional principal),
    status: (string-ascii 20),
    priority: uint,
    description: (string-ascii 500),
    findings: (optional (string-ascii 1000)),
    cause-determination: (optional (string-ascii 200)),
    case-closed-date: (optional uint)
  }
)

(define-map investigators
  { investigator: principal }
  {
    name: (string-ascii 100),
    specialization: (string-ascii 100),
    active: bool,
    active-cases: uint,
    total-cases: uint
  }
)

(define-map evidence-records
  { case-id: uint, evidence-id: uint }
  {
    evidence-type: (string-ascii 50),
    description: (string-ascii 300),
    collected-by: principal,
    collection-date: uint,
    chain-of-custody: (list 5 principal)
  }
)

(define-map case-evidence-count
  { case-id: uint }
  { count: uint }
)

;; Authorization Functions
(define-private (is-contract-owner)
  (is-eq tx-sender CONTRACT-OWNER)
)

(define-private (is-authorized-investigator (investigator principal))
  (match (map-get? investigators { investigator: investigator })
    investigator-data (get active investigator-data)
    false
  )
)

;; Investigator Management
(define-public (register-investigator
  (investigator principal)
  (name (string-ascii 100))
  (specialization (string-ascii 100)))
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (map-set investigators
      { investigator: investigator }
      {
        name: name,
        specialization: specialization,
        active: true,
        active-cases: u0,
        total-cases: u0
      }
    )
    (ok true)
  )
)

;; Case Reporting
(define-public (report-incident
  (incident-location (string-ascii 200))
  (incident-type (string-ascii 50))
  (description (string-ascii 500)))
  (let
    (
      (case-id (var-get next-case-id))
    )
    (asserts! (> (len incident-location) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)

    (map-set investigation-cases
      { case-id: case-id }
      {
        incident-location: incident-location,
        incident-type: incident-type,
        report-date: block-height,
        reporter: tx-sender,
        assigned-investigator: none,
        status: "reported",
        priority: u3, ;; Default medium priority
        description: description,
        findings: none,
        cause-determination: none,
        case-closed-date: none
      }
    )

    (map-set case-evidence-count
      { case-id: case-id }
      { count: u0 }
    )

    (var-set next-case-id (+ case-id u1))
    (ok case-id)
  )
)

;; Case Assignment
(define-public (assign-investigator (case-id uint) (investigator principal))
  (let
    (
      (case-data (unwrap! (map-get? investigation-cases { case-id: case-id }) ERR-CASE-NOT-FOUND))
    )
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (asserts! (is-authorized-investigator investigator) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status case-data) "reported") ERR-INVALID-STATUS)

    (map-set investigation-cases
      { case-id: case-id }
      (merge case-data {
        assigned-investigator: (some investigator),
        status: "investigating"
      })
    )

    ;; Update investigator active cases
    (update-investigator-active-cases investigator true)

    (ok true)
  )
)

;; Evidence Management
(define-public (add-evidence
  (case-id uint)
  (evidence-type (string-ascii 50))
  (description (string-ascii 300)))
  (let
    (
      (case-data (unwrap! (map-get? investigation-cases { case-id: case-id }) ERR-CASE-NOT-FOUND))
      (evidence-count-data (unwrap! (map-get? case-evidence-count { case-id: case-id }) ERR-CASE-NOT-FOUND))
      (evidence-id (get count evidence-count-data))
    )
    (asserts! (is-authorized-investigator tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (some tx-sender) (get assigned-investigator case-data)) ERR-NOT-AUTHORIZED)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)

    (map-set evidence-records
      { case-id: case-id, evidence-id: evidence-id }
      {
        evidence-type: evidence-type,
        description: description,
        collected-by: tx-sender,
        collection-date: block-height,
        chain-of-custody: (list tx-sender)
      }
    )

    (map-set case-evidence-count
      { case-id: case-id }
      { count: (+ evidence-id u1) }
    )

    (ok evidence-id)
  )
)

;; Case Closure
(define-public (close-case
  (case-id uint)
  (findings (string-ascii 1000))
  (cause-determination (string-ascii 200)))
  (let
    (
      (case-data (unwrap! (map-get? investigation-cases { case-id: case-id }) ERR-CASE-NOT-FOUND))
    )
    (asserts! (is-authorized-investigator tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (some tx-sender) (get assigned-investigator case-data)) ERR-NOT-AUTHORIZED)
    (asserts! (is-eq (get status case-data) "investigating") ERR-INVALID-STATUS)
    (asserts! (> (len findings) u0) ERR-INVALID-INPUT)

    (map-set investigation-cases
      { case-id: case-id }
      (merge case-data {
        status: "closed",
        findings: (some findings),
        cause-determination: (some cause-determination),
        case-closed-date: (some block-height)
      })
    )

    ;; Update investigator stats
    (update-investigator-active-cases tx-sender false)
    (update-investigator-total-cases tx-sender)

    (ok true)
  )
)

;; Private helper functions
(define-private (update-investigator-active-cases (investigator principal) (increment bool))
  (match (map-get? investigators { investigator: investigator })
    investigator-data
      (let
        (
          (current-active (get active-cases investigator-data))
          (new-active (if increment (+ current-active u1) (- current-active u1)))
        )
        (map-set investigators
          { investigator: investigator }
          (merge investigator-data { active-cases: new-active })
        )
      )
    false
  )
)

(define-private (update-investigator-total-cases (investigator principal))
  (match (map-get? investigators { investigator: investigator })
    investigator-data
      (map-set investigators
        { investigator: investigator }
        (merge investigator-data { total-cases: (+ (get total-cases investigator-data) u1) })
      )
    false
  )
)

;; Read-only functions
(define-read-only (get-case (case-id uint))
  (map-get? investigation-cases { case-id: case-id })
)

(define-read-only (get-investigator (investigator principal))
  (map-get? investigators { investigator: investigator })
)

(define-read-only (get-evidence (case-id uint) (evidence-id uint))
  (map-get? evidence-records { case-id: case-id, evidence-id: evidence-id })
)

(define-read-only (get-case-evidence-count (case-id uint))
  (map-get? case-evidence-count { case-id: case-id })
)

(define-read-only (get-next-case-id)
  (var-get next-case-id)
)
