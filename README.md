# Smart Contract Public Fire Marshal Services

A comprehensive blockchain-based fire marshal services system built on the Stacks blockchain using Clarity smart contracts. This system manages fire safety inspections, investigations, permits, education programs, and hazardous material oversight.

## System Overview

The Fire Marshal Services system consists of five interconnected smart contracts that handle different aspects of fire safety management:

### 1. Fire Safety Inspection Coordination Contract
- Schedules and tracks fire safety inspections
- Manages inspection results and compliance status
- Issues violation notices and tracks remediation
- Maintains inspection history for businesses and public buildings

### 2. Fire Investigation Management Contract
- Records fire incident reports
- Manages investigation assignments and progress
- Stores investigation findings and evidence
- Tracks case status from initial report to closure

### 3. Fireworks Permit and Safety Contract
- Issues permits for fireworks displays
- Manages permit applications and approvals
- Tracks safety compliance requirements
- Maintains permit history and violations

### 4. Fire Prevention Education Contract
- Coordinates fire safety education programs
- Manages school and community program schedules
- Tracks participation and completion rates
- Maintains educational resource inventory

### 5. Hazardous Material Storage Oversight Contract
- Monitors storage facilities for flammable materials
- Manages storage permits and compliance
- Tracks inspection schedules and results
- Maintains inventory of hazardous materials

## Key Features

- **Decentralized Management**: All fire marshal services are managed on-chain
- **Transparent Operations**: Public visibility of inspections, permits, and compliance
- **Immutable Records**: Permanent record keeping for investigations and inspections
- **Role-Based Access**: Different permission levels for marshals, inspectors, and public
- **Compliance Tracking**: Automated tracking of violations and remediation

## Contract Architecture

Each contract operates independently while maintaining data integrity through:
- Standardized data structures
- Consistent error handling
- Role-based permission systems
- Event logging for transparency

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm for testing
- Stacks wallet for deployment

### Installation

\`\`\`bash
git clone <repository-url>
cd fire-marshal-services
npm install
\`\`\`

### Testing

\`\`\`bash
npm test
\`\`\`

### Deployment

\`\`\`bash
clarinet deploy
\`\`\`

## Contract Addresses

After deployment, contract addresses will be available here:
- Fire Safety Inspection: \`<address>\`
- Fire Investigation: \`<address>\`
- Fireworks Permit: \`<address>\`
- Fire Prevention Education: \`<address>\`
- Hazardous Material Oversight: \`<address>\`

## Usage Examples

### Schedule Fire Inspection
\`\`\`clarity
(contract-call? .fire-safety-inspection schedule-inspection
"123 Main St"
"Restaurant"
u1640995200)
\`\`\`

### Issue Fireworks Permit
\`\`\`clarity
(contract-call? .fireworks-permit issue-permit
"City Park"
"July 4th Celebration"
u1688428800
u100)
\`\`\`

### Report Fire Incident
\`\`\`clarity
(contract-call? .fire-investigation report-incident
"456 Oak Ave"
"Structure Fire"
"Residential building fire")
\`\`\`

## API Reference

Detailed API documentation for each contract is available in the \`docs/\` directory.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions or support, please open an issue on GitHub or contact the development team.

