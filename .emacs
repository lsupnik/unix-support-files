;; Complete words wi/ M-enter
;; Note: you must byte-compile this file in a clean emacs environment or
;; it will cause weird problems. See comments in completion-11-4.el
;; (load-library "completion-11-4")
;; (initialize-completions)

;; Highlight matching parents
(show-paren-mode t)

;; turn off ctrl-z minimizing emacs if using gui
(if (display-graphic-p)
    (progn
      (disable-command 'suspend-frame)
      (global-unset-key "\C-x\C-z")
      (global-unset-key "\C-z")))

;; Fancy buffer and file selection
(require 'ido)
(ido-mode t)
(setq
 ido-max-prospects 6				; Less clutter in mini-buffer
 ido-auto-merge-work-directories-length -1	; Don't search in other directories
 ido-enable-flex-matching t			; Fuzzy matching
 )

;; Make buffer names unique by appending the directory in brackets
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

; Stop forcing me to spell out "yes"
(fset 'yes-or-no-p 'y-or-n-p)

; Stop leaving backup~ turds scattered everywhere
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))

;; Syntax highlighting
(global-font-lock-mode 1)

;;turn off insert key
(global-unset-key [insert])

;; Don't ignore .cp files when completing
(setq completion-ignored-extensions
      (mapcar (lambda (s) (if (string-equal s ".cp") nil s)) completion-ignored-extensions))


;; Set miscellaneous variables
(setq
 backup-by-copying-when-linked t
 font-lock-maximum-decoration t
 compilation-window-height 15
 compilation-scroll-output t
 compile-command "scons -j2 -D"
 delete-old-versions t
 diff-switches "-up"
 enable-recursive-minibuffers t
 fill-column 78
 find-file-existing-other-name t
 inhibit-startup-message t
 Info-enable-edit t
 kept-old-versions 1
 lazy-lock-minimum-size 5000
 ; Show line number is status bar
 line-number-mode t
 ; Mark still works even when region is not highlighted
 ; (note the CUA commands don't respect this)
 mark-even-if-inactive t
 ; Automatically add final newline before saving
 require-final-newline t
 next-line-add-newlines nil
 ; Keep the point in the same spot on the screen when scrolling
 scroll-preserve-screen-position t
 search-highlight t
 tags-revert-without-query t
 ; No warnings when visiting files through symlinks
 find-file-suppress-same-file-warnings t
 ; Move by actual lines, not display lines, when word-wrapped
 line-move-visual nil
 ; Nicely indent start of comments
 comment-style 'indent
 ; When wrapping long lines, do some caching to avoid horrible slowness (e.g. from htmldoc output
 ; in compile-mode)
 cache-long-line-scans t
 )

;; OS-specific customizations
(cond
 ;; Windows
 ((string-match "-nt" system-configuration)
  (progn
    ;; Use cygwin bash shell
    (setq explicit-shell-file-name "c:/bin/bash")
    (setq shell-file-name explicit-shell-file-name)))
 ; Mac OS
 ((string-match "darwin" system-configuration)
  ;; Default keybindings are all screwed up and Mac-like on Emacs 23.
  ;; Let's try to repair the damage.
  (if (> (string-to-number emacs-version) 22)
      (progn (setq mac-command-modifier 'meta)
	     (setq mac-option-modifier 'none)
	     (global-set-key [end] 'end-of-line)
	     (global-set-key [kp-delete] 'delete-char)
	     ))))


;; ========= GenArts C programming style =========
;;; prevent newlines from being inserted after semicolons when there
;;; is a non-blank following line.
(defun my-semicolon-criteria ()
  (save-excursion
    (if (and (eq last-command-char ?\;)
             (zerop (forward-line 1))
             (not (looking-at "^[ \t]*$")))
        'stop
      nil)))

(defun my-c-mode-hook ()
  (setq c-basic-offset 2)
  (setq c-hanging-comment-ender-p nil)
  (setq c-hanging-comment-start-p nil)
  ;; Labels offset by 1 from parent, but keep case stmts
  ;; offset by c-basic-offset.
  (c-set-offset 'label 1)
  (c-set-offset 'case-label 1)
  (c-set-offset 'innamespace 0)		;don't indent in namespaces
  (c-set-offset 'inextern-lang 0)	;don't indent in extern "C"
  (c-set-offset 'statement-case-intro (lambda (in)
					(- c-basic-offset 1)))
  (c-set-offset 'statement-case-open '-)
  (c-set-offset 'substatement-open 0)
  (c-set-offset 'statement-cont 'c-lineup-math)
					; prevent arg lists from going off right side of page:
					; longnamed_function(
					;     arg_t arg1,
					;     arg_t 2);
  (c-set-offset 'arglist-intro '++) ; 1st line in arg list (after open)
  (c-set-offset 'arglist-close '--)
  (turn-on-auto-fill)
  (c-toggle-hungry-state 1)
  (setq fill-column 77)
  (setq c-hanging-semi&comma-criteria
	(cons 'my-semicolon-criteria
	      c-hanging-semi&comma-criteria))
  (setq c-hanging-braces-alist
	'((brace-list-open)
	  (brace-list-close)
	  (brace-list-intro)
	  (brace-list-entry)
	  (substatement-open after)
	  (topmost-intro after)
	  (inline-open after)
	  (block-close . c-snug-do-while)
	  (extern-lang-open after)))

  (setq c-cleanup-list (cons 'defun-close-semi c-cleanup-list))
  (local-set-key "\C-cc" 'compile))

(add-hook 'c-mode-common-hook
	  'my-c-mode-hook)

;; Use C++ mode for CUDA files and CxxTest suites
(mapcar (lambda (regex)
	  (setq auto-mode-alist (cons (cons regex 'c++-mode) auto-mode-alist)))
	'("\\.cu\\'" "\\.cp\\'" "\\.t\\.h\\'"))
;; Use ObjC mode for MM (ObjC++) files
(setq auto-mode-alist (cons (cons "\\.mm\\'" 'objc-mode) auto-mode-alist))

;; ========= GenArts-specific tools and customizations =========

;; Genarts-specific customizations
(setq auto-mode-alist (cons '("SCons\\(truct\\|cript\\)\\'" . python-mode) auto-mode-alist))

;; Highlighting and stuff for compilation buffers
(add-hook 'compilation-mode-hook
	  (function
	   (lambda ()
	     (setq compilation-window-height 15)
	     (make-variable-buffer-local 'shell-file-name) ; so we can change the shell here if we want
	     (setq compilation-mode-font-lock-keywords
		   '(("^\"\\([^\"]*\", line [0-9]+:[ \t]*warning:[ \t]*\\)\\(.*$\\)"
		      2 font-lock-keyword-face)
		     ("^\"\\([^\"]*\", line [0-9]+:[ \t]*\\)\\(.*$\\)"
		      2 font-lock-function-name-face)))
	     )))


;;; SCons (with -D) starts builds from the top of the source tree, and it builds into
;;; an 'SBuild' subdir. But we want to find the original errors in the regular source dir,
;;; regardless of the current directory when we run M-x compile.
(defun process-error-filename (filename)
  (let ((case-fold-search t)
	;;; Top of our SVN working dir
	(dir (svn-base-dir (strip-sbuild (fix-win-path default-directory))))
	;;; Filename with SBuild stuff removed (but still containing subdir)
	(stripped-file (strip-sbuild (fix-win-path filename)))
	)
    (let ((path (concat dir "/" stripped-file)))
      (save-current-buffer
	(set-buffer "*Messages*")
	(insert (format "process-error-filename: current %s, file %s ==> %s\n" default-directory
			filename path)))
      ;;; If the path doesn't exist, give up and return the original filename
      (if (file-exists-p path) path
	(if (file-exists-p stripped-file)
	    stripped-file filename)))))

;;; Move up the directory hierarchy until we find the top of the SVN working dir
(defun svn-base-dir (dir)
  (if (file-exists-p (concat dir "../.svn"))
      (svn-base-dir (concat dir "../"))
    dir))

;;; Convert "\" to "/" so path-handling functions don't get confused
(defun fix-win-path (p)
  (replace-regexp-in-string "\\\\" "/" p))

;;; Strip Sbuild dirs from a pathname
(defun strip-sbuild (p)
  (replace-regexp-in-string
   "[Ss]?[Bb]uild/.*\\(final\\|dbg\\)[^/]*/" "" p))

;;; For emacs 21.1, this requires my patch to compile.el, which is in
;;; my email in the emacs folder (date around 10/25/2001).  Later
;;; versions should already have it.
(setq compilation-parse-errors-filename-function 'process-error-filename)

;; ;; always hilight XXX in programming modes
(mapcar (lambda (mode)
	  (font-lock-add-keywords
	   mode
	   '(("\\<XXX\\>" 0 font-lock-warning-face prepend)
	     ("\\<XXX:\\>" 0 font-lock-warning-face prepend)
	     )))
	'(c-mode c++-mode java-mode lisp-mode emacs-lisp-mode ruby-mode python-mode lua-mode))

;;; for Sapphire def-effects.text: indent (def ...) like a special
;;; form with one arg (the name), not like a defun.
(put 'def 'lisp-indent-function 1)

;; In C++, highlight new_check, delete_check, and safe_delete like keywords.
(font-lock-add-keywords
      'c++-mode
      '(("\\<\\(new_check\\)\\>" 0 font-lock-keyword-face append)
	("\\<\\(delete_check\\)\\>" 0 font-lock-keyword-face append)
	("\\<\\(safe_delete\\)\\>" 0 font-lock-keyword-face append)))


;; srcgrep command. Like M-x grep, but it runs our own srcgrep tool to search in your
;; current source tree.
;; This works best if the srcgrep executable is in your path: then you can run it from any subdirectory.
;; It will find the root of your tree and search everything.
(defvar srcgrep-history nil)
(defun srcgrep (command)
  (interactive
   (let ((default (thing-at-point 'symbol)))
     (list (read-string "Run srcgrep (like this): "
			(concat "srcgrep -nH " (if default (substring-no-properties default) nil))
			'srcgrep-history))))
  (grep command))
(defalias 'sg 'srcgrep)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

(add-to-list 'load-path "~/.emacs.d/lisp")
;; (let ((custom-theme-load-path "~/.emacs.d/"))
;;   (require 'color-theme-zenburn)
;;   (color-theme-zenburn)
;; )

;; Pretty color scheme
(require 'color-theme-zenburn)
(color-theme-zenburn)

(setq vc-handled-backends nil)

;; egg git
;; (require 'egg)

;; display which function the cursor currently resides in
(which-function-mode 1)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(which-function-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(which-func ((t (:foreground "cornflower blue")))))
(put 'suspend-frame 'disabled t)
