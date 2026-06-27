(function () {
    "use strict";

    var pathname = window.location.pathname;
    if (pathname.indexOf("/external-links/") !== -1 || pathname.lastIndexOf("/404.html") === pathname.length - 9) {
        return;
    }

    var main = document.querySelector(".content main");
    if (!main || document.querySelector(".donation-footer")) {
        return;
    }

    var root = typeof path_to_root === "string" ? path_to_root : "";
    var items = [
        { label: "微信", image: "wechat.png" },
        { label: "支付宝", image: "alipay.png" },
        { label: "KO-FI", image: "kofi.png" },
        { label: "OpenCollective", image: "opencollective.png" }
    ];

    var footer = document.createElement("section");
    footer.className = "donation-footer";
    footer.setAttribute("aria-labelledby", "donation-footer-title");

    var title = document.createElement("p");
    title.id = "donation-footer-title";
    title.className = "donation-footer__title";
    title.textContent = "校对不易 (^-^) 谢予支持";
    footer.appendChild(title);

    var button = document.createElement("a");
    button.className = "donation-footer__button";
    button.href = root + "markdown/sponsor.html";
    button.textContent = "打赏";
    footer.appendChild(button);

    var grid = document.createElement("div");
    grid.className = "donation-footer__grid";

    items.forEach(function (item) {
        var figure = document.createElement("figure");
        figure.className = "donation-footer__item";

        var image = document.createElement("img");
        image.className = "donation-footer__image";
        image.src = root + "res/imgs/donate/" + item.image;
        image.alt = item.label + "打赏二维码";
        image.loading = "lazy";
        image.decoding = "async";

        var caption = document.createElement("figcaption");
        caption.className = "donation-footer__label";
        caption.textContent = item.label;

        figure.appendChild(image);
        figure.appendChild(caption);
        grid.appendChild(figure);
    });

    footer.appendChild(grid);
    main.appendChild(footer);
}());