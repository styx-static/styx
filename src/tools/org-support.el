(require 'package)
(package-initialize)
(require 'use-package)
(use-package org)

(defvar styx-intro-splitter
  ;; The string used by styx to separate intro from content
  ">>>")

(org-babel-do-load-languages
 'org-babel-load-languages
 '(; Scripting
   (sh . t)
   (shell . t)))

(defun ck/org-confirm-babel-evaluate (lang body)
  (not (or
        ;; Scripting
        (string= lang "sh")
        (string= lang "shell")
	(string= lang "bash")
        ;; (string= lang "shell")
        (string= lang "emacs-lisp")
        (string= lang "perl")
        (string= lang "ruby")
        ;; Math
        (string= lang "octave")
        (string= lang "maxima")
        (string= lang "R")
        (string= lang "python")
        (string= lang "ipython")
        (string= lang "jupyter")
	(string= lang "jupyter-julia")
	(string= lang "jupyter-python")
	(string= lang "jupiter-R")
        (string= lang "julia")
        (string= lang "latex")
        (string= lang "dot")
	;; compiled
	(string= lang "cpp")
	(string= lang "C"))))

(setq org-confirm-babel-evaluate 'ck/org-confirm-babel-evaluate)

(defun compile-org-file ()
  (interactive)
  (message "compiling")
  (org-mode)
  (org-html-export-as-html nil nil nil t nil)
  (princ (buffer-string)))

(defun text (input)
  (mapconcat 'identity (mapcar (lambda (tag)
				 (substring-no-properties (car tag)))
			       input)  "\" \""))

;; buffer must be writeable in order to call org-export-get-environment,
;; wrap it with this
(defun ro-export-get-environment (&optional params)
  (let ((buffer-read-only nil))
    (org-export-get-environment params)))

(defun plist-get-as-text (plist attr)
  "Get attributes from the output of org-export-get-environment"
  (let ((str (car (plist-get plist attr))))
    (if str (substring-no-properties str) nil)))

;; (org-export-replace-region-by 'html)

(defun title-text (&optional throw)
  "Get the title of the org buffer.
   When throw is true, throws an error if no title is provided"
  (let ((title (jk-org-kwd "TITLE")))
    (if (not (eq title nil))
	(org-export-string-as title 'html t)
      (if throw
	  (error "Missing '#+title:' field!"))
      "")))

(defun list-tags ()
  (mapcar (lambda (tag)
	    (substring-no-properties (car tag)))
	  (org-global-tags-completion-table)))

(defun is-draft-p ()
  "Check if the '#+option:' draft is set to t or nil.
   If it's not defined, nil is assumed"
  (let ((draft (jk-org-kwd "DRAFT")))
	(or (string= draft "t")
	    (string= draft "true"))))

(defun styx-split-before-heading ()
  (save-excursion
    (outline-next-heading)
    (insert (concat styx-intro-splitter "\n"))))

(defun preprocess-org-file ()
  (interactive)
  (message "preprocessing")
  (org-mode)
  (let ((buffer-read-only nil))
    (styx-split-before-heading)
    (princ (concat "{---\n"
		   (format "title = \"%s\";\n" (title-text t))
		   (format "tags = [\"%s\"];\n" (text (org-get-buffer-tags)))
		   (format "draft = %s;\n" (if (is-draft-p) "true" "false"))
		   "---}\n" (buffer-string)))))

(defun jk-org-kwds ()
  "parse the buffer and return a cons list of (property . value)
from lines like:
#+PROPERTY: value"
  (org-element-map (org-element-parse-buffer 'element) 'keyword
                   (lambda (keyword) (cons (org-element-property :key keyword)
                                           (org-element-property :value keyword)))))

(defun jk-org-kwd (KEYWORD)
  "get the value of a KEYWORD in the form of #+KEYWORD: value"
  (cdr (assoc KEYWORD (jk-org-kwds))))
