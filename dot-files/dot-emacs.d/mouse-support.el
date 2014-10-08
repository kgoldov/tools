;; -*- Mode: EMACS-LISP; BASE: 10 -*-
;;
;; This software is distributed free of charge and is in the public
;; domain.  Anyone may use, duplicate or modify this program.  ICAD does
;; not restrict in any way the use of this software by anyone.
;; 
;; ICAD provides absolutely no warranty of any kind.  The entire risk as
;; to the quality and performance of this program is with you.  In no
;; event will ICAD be liable to you for damages, including any lost
;; profits, lost monies, or other special, incidental or consequential
;; damages arising out of the use of this program.
;;
;;   ICAD, Inc.
;;   201 Broadway
;;   Cambridge, MA 02139-1901
;;   United States of America
;;   (617) 868-2800
;;
;; Abstract:
;;
;; $Header: /fs/local/icad/emacs/II-5-0/RCS/mouse-support.el,v 1.3 1994/11/28 16:55:21 russell Exp $
;;
;; $Log: mouse-support.el,v $
;; Revision 1.3  1994/11/28 16:55:21  russell
;; fix meta-mouse functions to behave as documented
;;
; Revision 1.2  1994/09/28  18:05:37  russell
; removed all the things that are now done by emacs 19
;
; Revision 1.1  1994/09/28  14:56:14  russell
; Initial revision
;
; Revision 5.1  1994/02/17  23:50:56  steve
; Added an isc::record-source-file form
;
; Revision 5.0  1993/06/28  18:43:03  sean
; initial revision for post 4.0 development
;
; Revision 1.12  1993/04/20  15:27:53  steve
; Fix space dwimming char classes, whitespace is represented by a space not a tab.
;
; Revision 1.11  1993/04/16  16:09:32  steve
; Fix defvar syntax.
;
; Revision 1.10  1993/04/15  17:46:24  steve
; Generalize space dwimming routines after-spacep and before-spacep
; by introducing to variables,  *dwim-space-before-char-syntax-list*
; and *dwim-space-after-char-syntax-list* which are bound to lists of
; chars where that shouldn't be DWIMMED.
;
; Revision 1.9  1992/11/25  16:04:22  steve
; New heuristic for space DWIMMING.
;
; Revision 1.8  1992/11/13  23:01:06  steve
; Fix mouse scrolling so that it is done relative to
; window-coordinates rather than screen coordinates.
;
; Revision 1.7  1992/08/26  19:55:05  steve
; Use stacking menus for buffer list.
;
; Revision 1.6  1992/07/29  22:51:40  steve
; Better space DWIMMING for mouse-insert-left-paren-at-point.
;
; Revision 1.5  1992/07/29  16:11:15  steve
; Fixed Up x-buffer-menu to use stacking menus.
;
; Revision 1.4  1992/07/14  16:39:58  steve
; More improvements to mouse picking.  Enhance so that
; mouse picks go into the kill ring as well as into the
; cut buffer.  Added a Ctrl-shift mouse left binding for
; mouse-insert-newline.  Incorporated all of x-mouse-support.el
; with my fixes rather than requiring it.
;
; Revision 1.3  1992/06/15  19:25:23  steve
; Fix Up mouse-yank-expression to insert a space after the yank.
; insert-left-paren and insert-right-paren operate at point rather
; than at mouse location.
;
; Revision 1.2  1992/04/30  14:43:54  steve
; Fixed mouse-copy-as-kill-expression to handle copys at
; the beginning of a buffer.
;
; Revision 1.1  1992/04/24  17:35:40  steve
; Initial revision
;

;;
;; **********************************************************************
;;

;; First is all the code to cut and paste the current word

(defun move-to-x-y (point)
  "Move to screen coordinates given by POINT; return resulting location"
  (if point
      (let ((rel (coordinates-in-window-p point (selected-window))))
	(if rel (progn
		  (move-to-window-line (cdr rel))
		  (move-to-column (+ (car rel) (current-column)
				     (max 0 (1- (window-hscroll)))))))))
  (point))


(defvar *dwim-space-before-char-syntax-list* nil
  "Don't DWIM insertions when the char before point is in one of these classes.")

(setq *dwim-space-before-char-syntax-list* '(32 40 39 95 34))
				      ; whitespace open-paren expression-prefix symbol string

(defvar *dwim-space-after-char-syntax-list* nil
  "Don't DWIM insertions when the char after point is in one of these classes.")

(setq *dwim-space-after-char-syntax-list* '(32 41 95 46 34))
				      ; whitespace close-paren symbol puntuation string


(defun before-spacep ()
  "No space is required ath the beginning of an insertion if point
is at the beginning of a line, the beginning of the buffer or if 
the character at point is a member of the white-space, open-parenthesis, 
expression-prefix, symbol or punctuation syntax classes."
  (not (or (bobp)
	   (bolp)
	   (memq (char-syntax (char-after (1- (point))))
		 *dwim-space-before-char-syntax-list*))))

(defun ensure-space-before (str)
  (if (before-spacep)
      (progn
	(mouse-store-cut-buffer (concat (char-to-string ?\ ) str))
	(setq kill-ring (cons (concat (char-to-string ?\ ) (car kill-ring))
			      (cdr kill-ring)))))) 

(defun ensure-space-after (str)
  (if (after-spacep) 
      (progn
	(mouse-store-cut-buffer (concat str (char-to-string ?\ )))
	(setq kill-ring (cons (concat (car kill-ring) (char-to-string ?\ ))
			      (cdr kill-ring))))))

(defun mouse-insert-right-paren-at-point ()
  "Insert a closing parenthesis at the current cursor location."
  (interactive)
  (insert ")")
  (blink-matching-open)) 

(defun mouse-insert-left-paren-at-point ()
  "Insert an open parenthesis at the mouse location."
  (interactive)
  (if (before-spacep)
      (insert " (")
    (insert "(")))

(defun mouse-yank-expression ()
  (interactive)
  (setq last-command nil)
  (mouse-operate-on-expression 'copy-region-as-kill)
  (pad-with-blanks)
  (yank)) 

(defun mouse-store-cut-buffer (string) ()) ; nul out this as no longer needed

(defun mouse-get-cut-buffer () ())	; nul out this as no longer needed

(defun mouse-operate-on-expression (func)
  (let ((point (cdr (mouse-position))))
    (save-excursion
      (save-window-excursion
	(select-window (window-from-x-y))
	(move-to-x-y point)
	(if (not (char-after (point)))
	    (mouse-store-cut-buffer "")
	  (let ((syntax (char-syntax (char-after (point))))
		beg
		end) 
	    (cond
	     ((eq syntax ?\( )	; Forward-sexp
	      (setq beg (point))
	      (forward-sexp 1)
	      (setq end (point)))
	     ((eq syntax ?\) )	; Backward-sexp
	      (forward-char 1)
	      (setq beg (point))
	      (backward-sexp 1)
	      (setq end (point)))
	     ((or (eq syntax ?\_)	; Symbol Containing Mouse
		  (eq syntax ?\w))
	      (while 
		  (and (not (bobp))
		       (or
			(eq ?\_ (char-syntax (char-after (point))))
			(eq ?\w (char-syntax (char-after (point))))))
		(backward-char  1))
	      (if (not (bobp))
		  (setq beg (1+ (point)))
		(setq beg (point)))
	      (forward-char 1)
	      (forward-sexp 1)
	      (setq end (point)))	  
	     ((eolp)			; At end of line, get the whole line
	      (setq end (point))
	      (beginning-of-line 1)
	      (setq beg (point)))
	     (t			; mark sexp
	      (setq beg (point))
	      (forward-sexp 1)
	      (setq end (point)))
	     )
	    (funcall func beg end)
	    (mouse-store-cut-buffer (buffer-substring beg end))
	    ))))))

(defun window-from-x-y  ()
  "The window containing screen coordinates POINT."
  (let* ((point (cdr (mouse-position))))
    (if (> (cdr point)
	   (- (1- (screen-height)) (window-height (minibuffer-window))))
	(if (zerop (minibuffer-depth)) nil (minibuffer-window))
      (let* ((start (selected-window)) (w start) (which nil))
	(while (not (or (if (coordinates-in-window-p point w) (setq which w))
			(eq (setq w (next-window w)) start))))
	which))))

(defun pad-with-blanks ()
  "Pad with spaces at current value of POINT."
  (let ((point (point)))
    (save-excursion
      (goto-char point)
      (ensure-space-before nil)
      (save-excursion
	(goto-char point)
	(ensure-space-after nil)))))

(defun after-spacep ()
  "No space required is at the end of an insertion if point is at 
the end of line or end of buffer or if the character at point is 
a member of the white-space, close-parenthesis, symbol or 
punctuation syntax classes."
  (not (or (eobp)
	   (eolp)
	   (memq (char-syntax (char-after (point)))
		 *dwim-space-after-char-syntax-list*))))

;;; positioning in window
(defun ii:mouse-to-top (event)
  "move the line at the mouse to the top of the window"
  (interactive "e")
  (ii::mouse-to-where event 0))

(defun ii:mouse-to-middle (event)
  "move the line at the mouse to the middle of the window"
  (interactive "e")
  (ii::mouse-to-where event nil))

(defun ii:mouse-to-bottom (event)
  "move the line at the mouse to the bottom of the window"
  (interactive "e")
  (ii::mouse-to-where event -1))

(defun ii::mouse-to-where (event where)
  (let* ((location (second event))
	 (window (car location))
	 (char (second location))
	 (current-window (selected-window))
	 point)
    (select-window window)
    (setq point (point))
    (goto-char char)
    (recenter where)
    (if (pos-visible-in-window-p point window)
	(goto-char point)
      (goto-char (window-start)))
    (select-window current-window)))


;; setting the mouse event gives two instances for each click. Ignore the second one.
; (global-set-key [\C-mouse-1] 'ignore) 
; (global-set-key [\C-mouse-3] 'ignore)
; (global-set-key [\C-mouse-2] 'ignore)
; (global-set-key [\C-S-mouse-1] 'ignore)
; (global-set-key [\M-drag-mouse-1] 'ignore)   ; this is secondary selection, but interferes with mouse-to-top
; (global-set-key [\M-mouse-1] 'ignore)
; (global-set-key [\M-mouse-2] 'ignore)
; (global-set-key [\M-mouse-3] 'ignore)

; (global-set-key [\C-down-mouse-1] 'mouse-insert-left-paren-at-point)
; (global-set-key [\C-down-mouse-3] 'mouse-insert-right-paren-at-point)
; (global-set-key [\C-down-mouse-2] 'mouse-yank-expression)
; (global-set-key [\C-S-down-mouse-1] 'fi:lisp-mode-newline)
; (global-set-key [\M-down-mouse-1] 'ii:mouse-to-top)
; (global-set-key [\M-down-mouse-2] 'ii:mouse-to-middle)
; (global-set-key [\M-down-mouse-3] 'ii:mouse-to-bottom)


;; Use new emacs drag modeline rather than ICAD function
;; wrap it so we can select if it is not dragged
(require 'mldrag)
(defun ii:mldrag-drag-mode-line (start-event)
  (interactive "e")
  (let* ((start-event-window (car (car (cdr start-event)))) 
	 (original-edges (window-edges start-event-window)))
    (mldrag-drag-mode-line start-event)
    (when (equal original-edges (window-edges start-event-window))        ;in other words, it has not changed
      (select-window start-event-window))))
      
; (global-set-key [mode-line down-mouse-1] 'ii:mldrag-drag-mode-line)
; (global-set-key [vertical-line down-mouse-1] 'mldrag-drag-vertical-line)
; (global-set-key [vertical-scroll-bar S-down-mouse-1] 'mldrag-drag-vertical-line)

;; reset the C-mouse functions to S-mouse
; (global-set-key [S-down-mouse-3]       'mouse-set-font)
; (global-set-key [S-down-mouse-1]       'mouse-buffer-menu) 

(defun ii:get-mouse-position ()
  (let* ((mouse (mouse-position))
	 (mouse-frame (first mouse))
	 (mouse-location (cdr mouse))
	 (mouse-x (car mouse-location))
	 (mouse-y (cdr mouse-location))
	 (window (window-at mouse-x mouse-y mouse-frame))
	 (edges (window-edges window))
	 (y-up (- mouse-y (cadr edges)))
	 (y-down (- mouse-y -2 (cadddr edges))))
    (cons y-up y-down)) 
  )

(defun ii:bottom-to-mouse ()
  (interactive)
  (let ((y (cdr (ii:get-mouse-position))))
    (scroll-down y)))

(defun ii:top-to-mouse ()
  (interactive)
  (let ((y (car (ii:get-mouse-position))))
    (scroll-down y)))

(defun ii:middle-to-mouse ()
  (interactive)
  (let* ((mouse-position (ii:get-mouse-position))
	(y0 (car mouse-position))
	(y1 (cdr mouse-position))
	(y (ash (+ y0 y1 -2) -1)))
    (scroll-down y)))


; (global-set-key [M-S-mouse-1]       'ignore)
; (global-set-key [M-S-down-mouse-1]       'ii:top-to-mouse)
; (global-set-key [M-S-mouse-2]       'ignore)
; (global-set-key [M-S-down-mouse-2]       'ii:middle-to-mouse)
; (global-set-key [M-S-mouse-3]       'ignore)
; (global-set-key [M-S-down-mouse-3]       'ii:bottom-to-mouse)

;; ======================================================================
;; Provide all of thes to prevent any of them from loading later
(provide 'mouse-support)
;(provide 'x-mouse)
;(provide 'mouse)
;(provide 'x-mouse-support)
