;; title: LiveChain

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))
(define-constant err-already-exists (err u103))
(define-constant err-invalid-input (err u104))

(define-data-var next-animal-id uint u1)

(define-map animals
  uint
  {
    owner: principal,
    species: (string-ascii 50),
    breed: (string-ascii 50),
    birth-date: uint,
    gender: (string-ascii 10),
    parent-male: (optional uint),
    parent-female: (optional uint),
    location: (string-ascii 100),
    status: (string-ascii 20),
    created-at: uint
  }
)

(define-map health-records
  {animal-id: uint, record-id: uint}
  {
    veterinarian: principal,
    diagnosis: (string-ascii 200),
    treatment: (string-ascii 200),
    medication: (string-ascii 100),
    recovery-status: (string-ascii 50),
    record-date: uint,
    next-checkup: (optional uint)
  }
)

(define-map animal-health-counts
  uint
  uint
)

(define-map ownership-history
  {animal-id: uint, transfer-id: uint}
  {
    from-owner: principal,
    to-owner: principal,
    transfer-date: uint,
    transfer-reason: (string-ascii 100),
    price: (optional uint)
  }
)

(define-map animal-transfer-counts
  uint
  uint
)

(define-map authorized-vets
  principal
  bool
)

(define-map breeding-records
  uint
  {
    male-parent: uint,
    female-parent: uint,
    breeding-date: uint,
    expected-birth: uint,
    success: bool
  }
)

(define-map animal-locations
  {animal-id: uint, location-id: uint}
  {
    location: (string-ascii 100),
    moved-date: uint,
    moved-by: principal,
    reason: (string-ascii 100)
  }
)

(define-map animal-location-counts
  uint
  uint
)

(define-read-only (get-animal (animal-id uint))
  (map-get? animals animal-id)
)

(define-read-only (get-health-record (animal-id uint) (record-id uint))
  (map-get? health-records {animal-id: animal-id, record-id: record-id})
)

(define-read-only (get-ownership-history (animal-id uint) (transfer-id uint))
  (map-get? ownership-history {animal-id: animal-id, transfer-id: transfer-id})
)

(define-read-only (get-health-record-count (animal-id uint))
  (default-to u0 (map-get? animal-health-counts animal-id))
)

(define-read-only (get-transfer-count (animal-id uint))
  (default-to u0 (map-get? animal-transfer-counts animal-id))
)

(define-read-only (get-location-count (animal-id uint))
  (default-to u0 (map-get? animal-location-counts animal-id))
)

(define-read-only (is-authorized-vet (vet principal))
  (default-to false (map-get? authorized-vets vet))
)

(define-read-only (get-next-animal-id)
  (var-get next-animal-id)
)

(define-public (authorize-veterinarian (vet principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set authorized-vets vet true)
    (ok true)
  )
)

(define-public (revoke-veterinarian (vet principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-delete authorized-vets vet)
    (ok true)
  )
)

(define-public (register-animal 
  (species (string-ascii 50))
  (breed (string-ascii 50))
  (birth-date uint)
  (gender (string-ascii 10))
  (parent-male (optional uint))
  (parent-female (optional uint))
  (location (string-ascii 100))
  )
  (let ((animal-id (var-get next-animal-id)))
    (map-set animals animal-id {
      owner: tx-sender,
      species: species,
      breed: breed,
      birth-date: birth-date,
      gender: gender,
      parent-male: parent-male,
      parent-female: parent-female,
      location: location,
      status: "healthy",
      created-at: stacks-block-height
    })
    (map-set animal-location-counts animal-id u1)
    (map-set animal-locations {animal-id: animal-id, location-id: u1} {
      location: location,
      moved-date: stacks-block-height,
      moved-by: tx-sender,
      reason: "initial registration"
    })
    (var-set next-animal-id (+ animal-id u1))
    (ok animal-id)
  )
)

(define-public (add-health-record
  (animal-id uint)
  (diagnosis (string-ascii 200))
  (treatment (string-ascii 200))
  (medication (string-ascii 100))
  (recovery-status (string-ascii 50))
  (next-checkup (optional uint))
  )
  (let (
    (animal (unwrap! (map-get? animals animal-id) err-not-found))
    (record-count (get-health-record-count animal-id))
    (new-record-id (+ record-count u1))
  )
    (asserts! (is-authorized-vet tx-sender) err-unauthorized)
    (map-set health-records {animal-id: animal-id, record-id: new-record-id} {
      veterinarian: tx-sender,
      diagnosis: diagnosis,
      treatment: treatment,
      medication: medication,
      recovery-status: recovery-status,
      record-date: stacks-block-height,
      next-checkup: next-checkup
    })
    (map-set animal-health-counts animal-id new-record-id)
    (ok new-record-id)
  )
)

(define-public (transfer-ownership
  (animal-id uint)
  (new-owner principal)
  (transfer-reason (string-ascii 100))
  (price (optional uint))
  )
  (let (
    (animal (unwrap! (map-get? animals animal-id) err-not-found))
    (current-owner (get owner animal))
    (transfer-count (get-transfer-count animal-id))
    (new-transfer-id (+ transfer-count u1))
  )
    (asserts! (is-eq tx-sender current-owner) err-unauthorized)
    (map-set animals animal-id (merge animal {owner: new-owner}))
    (map-set ownership-history {animal-id: animal-id, transfer-id: new-transfer-id} {
      from-owner: current-owner,
      to-owner: new-owner,
      transfer-date: stacks-block-height,
      transfer-reason: transfer-reason,
      price: price
    })
    (map-set animal-transfer-counts animal-id new-transfer-id)
    (ok new-transfer-id)
  )
)

(define-public (update-location
  (animal-id uint)
  (new-location (string-ascii 100))
  (reason (string-ascii 100))
  )
  (let (
    (animal (unwrap! (map-get? animals animal-id) err-not-found))
    (current-owner (get owner animal))
    (location-count (get-location-count animal-id))
    (new-location-id (+ location-count u1))
  )
    (asserts! (is-eq tx-sender current-owner) err-unauthorized)
    (map-set animals animal-id (merge animal {location: new-location}))
    (map-set animal-locations {animal-id: animal-id, location-id: new-location-id} {
      location: new-location,
      moved-date: stacks-block-height,
      moved-by: tx-sender,
      reason: reason
    })
    (map-set animal-location-counts animal-id new-location-id)
    (ok new-location-id)
  )
)

(define-public (update-animal-status
  (animal-id uint)
  (new-status (string-ascii 20))
  )
  (let ((animal (unwrap! (map-get? animals animal-id) err-not-found)))
    (asserts! (or (is-eq tx-sender (get owner animal)) (is-authorized-vet tx-sender)) err-unauthorized)
    (map-set animals animal-id (merge animal {status: new-status}))
    (ok true)
  )
)

(define-public (record-breeding
  (male-parent uint)
  (female-parent uint)
  (breeding-date uint)
  (expected-birth uint)
  )
  (let (
    (male-animal (unwrap! (map-get? animals male-parent) err-not-found))
    (female-animal (unwrap! (map-get? animals female-parent) err-not-found))
    (breeding-id (var-get next-animal-id))
  )
    (asserts! (is-eq tx-sender (get owner male-animal)) err-unauthorized)
    (asserts! (is-eq tx-sender (get owner female-animal)) err-unauthorized)
    (map-set breeding-records breeding-id {
      male-parent: male-parent,
      female-parent: female-parent,
      breeding-date: breeding-date,
      expected-birth: expected-birth,
      success: false
    })
    (ok breeding-id)
  )
)

(define-public (confirm-breeding-success (breeding-id uint))
  (let ((breeding-record (unwrap! (map-get? breeding-records breeding-id) err-not-found)))
    (asserts! (is-authorized-vet tx-sender) err-unauthorized)
    (map-set breeding-records breeding-id (merge breeding-record {success: true}))
    (ok true)
  )
)

(define-read-only (get-breeding-record (breeding-id uint))
  (map-get? breeding-records breeding-id)
)

(define-read-only (get-animal-location-history (animal-id uint) (location-id uint))
  (map-get? animal-locations {animal-id: animal-id, location-id: location-id})
)
