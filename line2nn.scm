;; Publish every line from stdin on a nanomsg socket. The socket is
;; given as a command-line argument

(use nanomsg data-structures extras matchable ports)

(define cla command-line-arguments)

;; TODO: add support for req? on req's, we could (display (nn-recv s))
(define (usage #!optional (msg ""))
  (error (conc msg "\n"
               "usage: " (car (argv))
               " <nn-protocol> [ --bind <nn-endpoint> | --connect <nn-endpoint> ] ...\n"
               "protocols include: pub push bus")))

;; returns two values: (<bind-endpoints> <connect-endpoints)
;; (fold-endpoints '("--bind" "b1" "-x" "--connect" "c1" "--bind" "b2"))
(define (fold-endpoints args)
  (let loop ((args args)
             (binds '())
             (connects '()))
    (match args
      (("--bind" endpoint rest ...)
       (loop rest
             (cons endpoint binds)
             connects))
      (("--connect" endpoint rest ...)
       (loop rest
             binds
             (cons endpoint connects)))
      ((unknown rest ...)
       (loop rest binds connects ))
      (else (values binds connects)))))

(if (null? (cla)) (usage))

(define nn-protocol (string->symbol (car (cla))))

(define-values (binds connects)
  (fold-endpoints (cdr (cla))))

(if (and (null? binds)
         (null? connects))
    (usage "error: no valid endpoints. use --connect / --bind"))

;; Nanomsg init
(define nnsock (nn-socket nn-protocol))
(for-each (cut nn-bind    nnsock <>) binds)
(for-each (cut nn-connect nnsock <>) connects)

(port-for-each
 (lambda (line) (nn-send nnsock line))
 read-line)

;; Cleanup
(nn-close nnsock)
