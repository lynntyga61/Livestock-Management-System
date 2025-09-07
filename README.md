# 🐄 LiveChain - Livestock Management System

A blockchain-based system for tracking livestock health, provenance, and ownership built on the Stacks blockchain using Clarity smart contracts.

## 🌟 Features

- 📋 **Animal Registration**: Register livestock with complete lineage tracking
- 🏥 **Health Records**: Veterinarian-managed health tracking and treatment history
- 🤝 **Ownership Transfers**: Secure ownership changes with complete audit trail
- 📍 **Location Tracking**: Track animal movements and current locations
- 👥 **Breeding Records**: Record and verify breeding activities
- 🔐 **Access Control**: Role-based permissions for veterinarians and owners

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- [Stacks CLI](https://github.com/blockstack/stacks-blockchain) (optional)

### Installation

1. Clone the repository
2. Navigate to the project directory
3. Run `clarinet check` to verify the contract

## 📖 Contract Functions

### 🏗️ Setup Functions

#### `authorize-veterinarian`
```clarity
(authorize-veterinarian (vet principal))
```
Authorizes a veterinarian to add health records (owner only).

#### `revoke-veterinarian`
```clarity
(revoke-veterinarian (vet principal))
```
Revokes veterinarian authorization (owner only).

### 🐮 Animal Management

#### `register-animal`
```clarity
(register-animal species breed birth-date gender parent-male parent-female location)
```
Registers a new animal in the system. Returns the animal ID.

**Parameters:**
- `species`: Animal species (e.g., "cattle", "sheep")
- `breed`: Specific breed 
- `birth-date`: Birth date as block height
- `gender`: "male" or "female"
- `parent-male`: Optional male parent ID
- `parent-female`: Optional female parent ID  
- `location`: Current location string

#### `transfer-ownership`
```clarity
(transfer-ownership animal-id new-owner transfer-reason price)
```
Transfers ownership of an animal to a new owner.

#### `update-location`
```clarity
(update-location animal-id new-location reason)
```
Updates an animal's location with tracking history.

#### `update-animal-status`
```clarity
(update-animal-status animal-id new-status)
```
Updates animal health status (owner or vet only).

### 🏥 Health Management

#### `add-health-record`
```clarity
(add-health-record animal-id diagnosis treatment medication recovery-status next-checkup)
```
Adds a health record (authorized veterinarians only).

### 🐄 Breeding Management

#### `record-breeding`
```clarity
(record-breeding male-parent female-parent breeding-date expected-birth)
```
Records a breeding event between two animals.

#### `confirm-breeding-success`
```clarity
(confirm-breeding-success breeding-id)
```
Confirms successful breeding (veterinarian only).

## 🔍 Read-Only Functions

### Data Retrieval
- `get-animal`: Get animal details by ID
- `get-health-record`: Get specific health record
- `get-ownership-history`: Get ownership transfer history
- `get-breeding-record`: Get breeding record details
- `get-animal-location-history`: Get location movement history

### Counts & Status
- `get-health-record-count`: Number of health records for an animal
- `get-transfer-count`: Number of ownership transfers
- `get-location-count`: Number of location changes
- `is-authorized-vet`: Check if principal is authorized veterinarian
- `get-next-animal-id`: Get the next animal ID to be assigned

## 🏗️ Data Structures

### Animal Record
```clarity
{
  owner: principal,
  species: string-ascii,
  breed: string-ascii,
  birth-date: uint,
  gender: string-ascii,
  parent-male: optional uint,
  parent-female: optional uint,
  location: string-ascii,
  status: string-ascii,
  created-at: uint
}
```

### Health Record
```clarity
{
  veterinarian: principal,
  diagnosis: string-ascii,
  treatment: string-ascii,
  medication: string-ascii,
  recovery-status: string-ascii,
  record-date: uint,
  next-checkup: optional uint
}
```

## 🔐 Access Control

- **Contract Owner**: Can authorize/revoke veterinarians
- **Animal Owners**: Can transfer ownership, update locations, register animals
- **Authorized Veterinarians**: Can add health records, update animal status, confirm breeding
- **Public**: Can read all records (transparency)

## ⚠️ Error Codes

- `u100`: Owner only operation
- `u101`: Record not found
- `u102`: Unauthorized access
- `u103`: Record already exists
- `u104`: Invalid input parameters

## 🧪 Testing

Run the test suite:
```bash
clarinet test
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure they pass
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built on the Stacks blockchain
- Powered by Clarity smart contracts
- Designed for livestock industry transparency
