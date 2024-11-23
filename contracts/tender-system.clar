;; Public Tender System Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-tender-closed (err u101))
(define-constant err-low-bid (err u102))
(define-constant err-tender-not-exists (err u103))
(define-constant err-already-exists (err u104))

;; Data Variables
(define-map tenders
    { tender-id: uint }
    {
        title: (string-ascii 100),
        description: (string-utf8 500),
        start-block: uint,
        end-block: uint,
        minimum-bid: uint,
        winner: (optional principal),
        lowest-bid: uint,
        status: (string-ascii 20)
    }
)

(define-map bids
    { tender-id: uint, bidder: principal }
    { amount: uint }
)

(define-data-var tender-nonce uint u0)

;; Private Functions
(define-private (is-tender-active (tender-id uint))
    (let (
        (tender (unwrap! (map-get? tenders { tender-id: tender-id }) (err false)))
        (current-block block-height)
    )
    (and
        (>= current-block (get start-block tender))
        (<= current-block (get end-block tender))
        (is-eq (get status tender) "ACTIVE")
    ))
)

;; Public Functions
(define-public (create-tender (title (string-ascii 100)) (description (string-utf8 500)) (duration uint) (minimum-bid uint))
    (let (
        (tender-id (var-get tender-nonce))
        (start-block block-height)
        (end-block (+ block-height duration))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-none (map-get? tenders { tender-id: tender-id })) err-already-exists)
    (map-set tenders
        { tender-id: tender-id }
        {
            title: title,
            description: description,
            start-block: start-block,
            end-block: end-block,
            minimum-bid: minimum-bid,
            winner: none,
            lowest-bid: u0,
            status: "ACTIVE"
        }
    )
    (var-set tender-nonce (+ tender-id u1))
    (ok tender-id))
)

(define-public (submit-bid (tender-id uint) (bid-amount uint))
    (let (
        (tender (unwrap! (map-get? tenders { tender-id: tender-id }) err-tender-not-exists))
        (current-lowest (get lowest-bid tender))
    )
    (asserts! (is-tender-active tender-id) err-tender-closed)
    (asserts! (>= (get minimum-bid tender) bid-amount) err-low-bid)
    
    (if (or (is-eq current-lowest u0) (< bid-amount current-lowest))
        (begin
            (map-set tenders
                { tender-id: tender-id }
                (merge tender {
                    lowest-bid: bid-amount,
                    winner: (some tx-sender)
                })
            )
            (map-set bids
                { tender-id: tender-id, bidder: tx-sender }
                { amount: bid-amount }
            )
            (ok true)
        )
        (err false))
    )
)

(define-public (close-tender (tender-id uint))
    (let (
        (tender (unwrap! (map-get? tenders { tender-id: tender-id }) err-tender-not-exists))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set tenders
        { tender-id: tender-id }
        (merge tender { status: "CLOSED" })
    )
    (ok true))
)

;; Read-only Functions
(define-read-only (get-tender (tender-id uint))
    (ok (map-get? tenders { tender-id: tender-id }))
)

(define-read-only (get-bid (tender-id uint) (bidder principal))
    (ok (map-get? bids { tender-id: tender-id, bidder: bidder }))
)
