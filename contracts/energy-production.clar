;; Energy Production Contract

;; Define constants for energy types
(define-constant ENERGY-TYPE-SOLAR u1)
(define-constant ENERGY-TYPE-WIND u2)
(define-constant ENERGY-TYPE-HYDRO u3)

;; Define data structures
(define-map energy-producers
  { producer-id: uint }
  {
    owner: principal,
    energy-type: uint,
    total-production: uint,
    last-updated: uint
  }
)

(define-data-var next-producer-id uint u1)

;; Functions
(define-public (register-producer (energy-type uint))
  (let
    ((producer-id (var-get next-producer-id)))
    (map-set energy-producers
      { producer-id: producer-id }
      {
        owner: tx-sender,
        energy-type: energy-type,
        total-production: u0,
        last-updated: block-height
      }
    )
    (var-set next-producer-id (+ producer-id u1))
    (ok producer-id)
  )
)

(define-public (record-production (producer-id uint) (amount uint))
  (match (map-get? energy-producers { producer-id: producer-id })
    producer
      (if (is-eq (get owner producer) tx-sender)
        (ok (map-set energy-producers
          { producer-id: producer-id }
          (merge producer
            {
              total-production: (+ (get total-production producer) amount),
              last-updated: block-height
            }
          )
        ))
        (err u403)
      )
    (err u404)
  )
)

(define-read-only (get-producer-info (producer-id uint))
  (map-get? energy-producers { producer-id: producer-id })
)

(define-read-only (get-total-production)
  (var-get next-producer-id)
)

