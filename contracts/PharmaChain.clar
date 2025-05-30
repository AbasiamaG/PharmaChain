;; PharmaChain - Pharmaceutical supply chain verification system
(define-map medications uint {
  manufacturer: principal,
  drug-name: (string-utf8 64),
  formulation-details: (string-utf8 256),
  batch-date: uint,
  production-facility: (string-utf8 64),
  quality-verified: bool
})

(define-map manufacturer-batches principal (list 100 uint))
(define-map quality-inspectors principal bool)
(define-data-var batch-id-tracker uint u0)

;; Error codes
(define-constant err-not-manufacturer (err u400))
(define-constant err-not-inspector (err u401))
(define-constant err-medication-not-found (err u402))
(define-constant err-permission-denied (err u403))
(define-constant err-batch-limit-reached (err u404))
(define-constant err-invalid-inspector-address (err u405))
(define-constant err-invalid-drug-name (err u406))
(define-constant err-invalid-formulation (err u407))
(define-constant err-invalid-batch-date (err u408))
(define-constant err-invalid-facility-name (err u409))
(define-constant err-invalid-batch-id (err u410))

;; Contract supervisor for quality control
(define-constant contract-supervisor tx-sender)

;; Register quality inspector
(define-public (register-quality-inspector (inspector principal))
  (begin
    ;; Check if sender is contract supervisor
    (asserts! (is-eq tx-sender contract-supervisor) err-permission-denied)
    
    ;; Validate inspector principal
    (asserts! (not (is-eq inspector 'SP000000000000000000002Q6VF78)) err-invalid-inspector-address)
    
    ;; Add inspector to registry
    (ok (map-set quality-inspectors inspector true))
  )
)

;; Register medication batch
(define-public (register-medication-batch 
  (drug-name (string-utf8 64)) 
  (formulation-details (string-utf8 256)) 
  (batch-date uint) 
  (production-facility (string-utf8 64)))
  (let
    ((batch-id (var-get batch-id-tracker))
     (manufacturer tx-sender)
     (current-batches (default-to (list) (map-get? manufacturer-batches manufacturer))))
    
    ;; Validate inputs
    (asserts! (> (len drug-name) u0) err-invalid-drug-name)
    (asserts! (> (len formulation-details) u0) err-invalid-formulation)
    (asserts! (> batch-date u0) err-invalid-batch-date)
    (asserts! (> (len production-facility) u0) err-invalid-facility-name)
    
    ;; Check batch registration limit
    (asserts! (< (len current-batches) u100) err-batch-limit-reached)
    
    ;; Store medication batch information
    (map-set medications batch-id {
      manufacturer: manufacturer,
      drug-name: drug-name,
      formulation-details: formulation-details,
      batch-date: batch-date,
      production-facility: production-facility,
      quality-verified: false
    })
    
    ;; Update manufacturer's batch list
    (let 
      ((updated-batch-list (unwrap-panic (as-max-len? (concat (list batch-id) current-batches) u100))))
      (map-set manufacturer-batches manufacturer updated-batch-list)
    )
    
    ;; Increment batch ID tracker
    (var-set batch-id-tracker (+ batch-id u1))
    
    (ok batch-id)))

;; Verify medication quality
(define-public (verify-medication-quality (batch-id uint))
  (begin
    ;; Validate batch ID
    (asserts! (< batch-id (var-get batch-id-tracker)) err-invalid-batch-id)
    
    (let
      ((medication (unwrap! (map-get? medications batch-id) err-medication-not-found)))
      
      ;; Check if sender is quality inspector
      (asserts! (default-to false (map-get? quality-inspectors tx-sender)) err-not-inspector)
      
      ;; Update medication quality verification status
      (ok (map-set medications batch-id (merge medication {quality-verified: true})))
    )
  )
)

;; Get medication batch details
(define-read-only (get-medication-batch (batch-id uint))
  (map-get? medications batch-id))

;; Get manufacturer's batches
(define-read-only (get-manufacturer-batches (manufacturer principal))
  (default-to (list) (map-get? manufacturer-batches manufacturer)))

;; Check quality inspector status
(define-read-only (is-quality-inspector (address principal))
  (default-to false (map-get? quality-inspectors address)))