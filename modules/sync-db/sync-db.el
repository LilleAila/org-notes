(require 'org)
(require 'org-roam)

(let ((input-dir (nth 0 command-line-args-left))
      (output-db (nth 1 command-line-args-left)))

  (unless (and input-dir output-db)
    (error "Usage: emacs --batch -l sync-db.el -- <input-dir> <output-db>"))

  (setq org-roam-directory (expand-file-name input-dir))
  (setq org-roam-db-location (expand-file-name output-db))

  (message "Building org-roam database for: %s" org-roam-directory)
  (message "Saving database to: %s" org-roam-db-location)

  (org-roam-db-sync)
  (message "Database sync complete.")

  (setq command-line-args-left nil))
