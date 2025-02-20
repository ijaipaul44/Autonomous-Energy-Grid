;; Energy Consumption Contract

;; Define data structures
(define-map energy-consumers
  { consumer-id: uint }
  {
    owner: principal,
    total-consumption: uint,
    last-updated: uint
  }
)

(define-data-var next-consumer-id uint u1)
(define-data-var total-consumption uint u0)

;; Functions
(define-public (register-consumer)
  (let
    ((consumer-id (var-get next-consumer-id)))
    (map-set energy-consumers
      { consumer-id: consumer-id }
      {
        owner: tx-sender,
        total-consumption: u0,
        last-updated: block-height
      }
    )
    (var-set next-consumer-id (+ consumer-id u1))
    (ok consumer-id)
  )
)

(define-public (record-consumption (consumer-id uint) (amount uint))
  (match (map-get? energy-consumers { consumer-id: consumer-id })
    consumer
      (if (is-eq (get owner consumer) tx-sender)
        (let
          ((new-total (+ (get total-consumption consumer) amount)))
          (var-set total-consumption (+ (var-get total-consumption) amount))
          (ok (map-set energy-consumers
            { consumer-id: consumer-id }
            (merge consumer
              {
                total-consumption: new-total,
                last-updated: block-height
              }
            )
          ))
        )
        (err u403)
      )
    (err u404)
  )
)

(define-read-only (get-consumer-info (consumer-id uint))
  (map-get? energy-consumers { consumer-id: consumer-id })
)

(define-read-only (get-total-consumption)
  (var-get total-consumption)
)

