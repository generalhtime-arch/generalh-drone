(() => {
  "use strict";

  document.documentElement.classList.add("js");

  const menuButton = document.querySelector("[data-menu-button]");
  const navigation = document.querySelector("[data-site-nav], #site-navigation");

  if (menuButton && navigation) {
    const closeMenu = () => {
      menuButton.setAttribute("aria-expanded", "false");
      navigation.classList.remove("is-open");
    };

    menuButton.addEventListener("click", () => {
      const isOpen = menuButton.getAttribute("aria-expanded") === "true";
      menuButton.setAttribute("aria-expanded", String(!isOpen));
      navigation.classList.toggle("is-open", !isOpen);
    });

    navigation.addEventListener("click", (event) => {
      if (event.target.closest("a")) closeMenu();
    });

    window.addEventListener("resize", () => {
      if (window.innerWidth >= 900) closeMenu();
    });
  }

  document.querySelectorAll("[data-current-year]").forEach((element) => {
    element.textContent = new Date().getFullYear();
  });

  // 開校告知は指定日時を過ぎると自動で非表示にします。
  // 表示期間を延長する場合は、HTML の data-launch-end を更新してください。
  document.querySelectorAll("[data-launch-notice]").forEach((notice) => {
    const endAt = Date.parse(notice.dataset.launchEnd || "");
    if (Number.isFinite(endAt) && Date.now() > endAt) notice.remove();
  });

  // 予約フォームURLはここで一元管理します。通常リンクにすることで、資格状況に応じた
  // 分岐フォームを別サイト側で安全に運用できます。
  const bookingUrl = "https://booking-v2.general-h.com/drone/";
  document.querySelectorAll("[data-reservation-cta]").forEach((link) => {
    link.href = bookingUrl;
  });

  // 全ページのヘッダーから、同じ予約フォームへ到達できるようにします。
  document.querySelectorAll(".site-nav .button-primary").forEach((link) => {
    link.href = bookingUrl;
    link.textContent = "講習を予約する";
    link.setAttribute("aria-label", "講習を予約する（予約フォームへ）");
  });
})();
