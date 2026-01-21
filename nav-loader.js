(function () {
  const navHost = document.getElementById("nav-placeholder");
  if (!navHost) return;

  fetch("/nav.html")
    .then(r => r.text())
    .then(html => {
      navHost.innerHTML = html;

      // Clear old actives
      navHost.querySelectorAll(".filetree__item.is-active")
        .forEach(a => a.classList.remove("is-active"));

      // Root-relative current path
      const current = (location.pathname === "/") ? "/index.html" : location.pathname;

      // Mark active link (exact match)
      const link = navHost.querySelector(`a[href="${current}"]`);
      if (link) link.classList.add("is-active");

      // Auto-open the folder containing the active link
      if (link) {
        const folder = link.closest("details.filetree__folder");
        if (folder) folder.open = true;
      }

      navHost.classList.add("is-loaded");
    })
    .catch(() => navHost.classList.add("is-loaded"));
})();

