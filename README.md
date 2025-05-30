# PharmaChain

PharmaChain is a blockchain-based pharmaceutical supply chain verification platform built on Stacks blockchain, ensuring transparent tracking and quality verification of medications from production to distribution.

## Features

- **Batch Registration**: Pharmaceutical manufacturers can register medication batches with detailed information
- **Quality Verification**: Certified inspectors can verify medication quality and safety
- **Supply Chain Transparency**: Complete visibility of drug formulation and production details
- **Immutable Records**: Blockchain-based records prevent counterfeit medications

## Smart Contract Functions

### Administration
- `register-quality-inspector`: Add certified quality inspectors for medication verification

### Manufacturer Functions
- `register-medication-batch`: Register new medication batch with production details
- `get-manufacturer-batches`: View all batches registered by a manufacturer

### Quality Control
- `verify-medication-quality`: Quality inspectors can verify medication safety
- `is-quality-inspector`: Check if an address is a certified inspector

### Data Access
- `get-medication-batch`: Retrieve complete batch information and verification status

## Getting Started

1. Clone this repository
2. Install [Clarinet](https://github.com/hirosystems/clarinet)
3. Run `clarinet check` to verify the contract
4. Deploy using Clarinet or Stacks CLI

## For Manufacturers

Register medication batches by providing:
- Drug name and identification
- Formulation details and ingredients
- Batch production date
- Production facility location

## For Quality Inspectors

Certified inspectors can review and verify medication batches, ensuring pharmaceutical safety standards.