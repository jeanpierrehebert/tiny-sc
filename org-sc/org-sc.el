
(defun org-sc-eval (replace-p)
  "Evaluate contents of org-mode element as SuperCollider code.
If inside a section, evaluate whole contents of section.
If inside a src block, evaluate contents of block."
  (interactive "P")
  (let* ((element (org-element-at-point))
         (plist (cadr element))
         end
         (string
          (if (equal (car element) 'src-block)
              (plist-get (cadr element) :value)
            (save-excursion
              (save-restriction
                (widen)
                (org-back-to-heading)
                (setq plist (cadr (org-element-at-point)))
                (setq end (plist-get plist :end))
                (goto-char (plist-get plist :contents-begin))
                ;; skip property drawer if it exists:
                (setq element (org-element-at-point))
                (if (equal 'property-drawer (car element))
                    (goto-char (plist-get (cadr element) :end)))
                (buffer-substring (point) end))))))
    (org-sc-eval-string-with-id string replace-p)))

(defun org-sc-eval-string-with-id (string &optional replace-p)
  "Eval string in SuperCollider, providing the id of the section
from which the string originates and the number of times that
this section has been evaluated as environment variables.
If replace-p is not nil, then remove all processes from the previous
evaluation of this section before evaluating the string."
  ;; UNDER DEVELOPMENT
  (let ((eval-id (or (org-entry-get (point) "eval-id") "1"))
        (source-id (org-id-get-create)))
    (message "eval-id: %s, source-id: %s" eval-id source-id)
    (if replace-p
        (sclang-eval-string
         (concat
          "ProcessRegistry.removeProcessesForID('"
          source-id
          "', "
          eval-id
          ");"
          ))
      (setq eval-id (format "%d" (+ 1 (eval (read eval-id))))))
    (org-set-property "eval-id" eval-id)
    (sclang-eval-string
     (concat
      "(source_id: '"
      source-id
      "', eval_id: "
      eval-id
      ") use: {\n"
      string
      "\n}")
     t)
    ))

(defun org-sc-eval-next ()
  "Go to next org-mode section and evaluate its contents as SuperCollider code."
  (interactive)
  (outline-next-heading)
  (org-sc-eval))

(defun org-sc-eval-previous ()
  "Go to previous org-mode section and evaluate its contents as SuperCollider code."
  (interactive)
  (outline-previous-heading)
  (org-sc-eval))

(defun org-sc-stop-section-processes ()
  "Stop the nodes, routines, patterns started from the current org-section."
  (interactive)
  (sclang-eval-string
   (concat
    "ProcessRegistry.removeProcessesForID('"
    (org-id-get-create)
    "')")))

(define-key org-mode-map (kbd "C-M-x") 'org-sc-eval)
(define-key org-mode-map (kbd "C-M-n") 'org-sc-eval-next)
(define-key org-mode-map (kbd "C-M-p") 'org-sc-eval-previous)
;; this overrides the default binding org-schedule, which I do not use often:
(define-key org-mode-map (kbd "C-c C-s") 'sclang-main-stop)
(define-key org-mode-map (kbd "H-C-r") 'sclang-process-registry-gui)
(define-key org-mode-map (kbd "C-c C-M-.") 'org-sc-stop-section-processes)
