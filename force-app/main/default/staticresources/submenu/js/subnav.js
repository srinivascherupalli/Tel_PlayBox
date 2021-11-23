jQuery(function ($) {
    $(function () {
        var headerEL = document.querySelector('.header-inner');
        function addNavToggle() {
            $(".comm-navigation nav").before('<input type="checkbox" class="dNavToggle" id="dNavToggle" name="deskToggle"><label for="dNavToggle"></label>');
        }
        setTimeout(function () {
            //addNavToggle();
            $(".header-inner .comm-navigation").before('<input type="checkbox" class="dNavToggle" id="dNavToggle" name="deskToggle"><label for="dNavToggle"></label>');
            //alert("hello");
        }, 2000);
        window.addEventListener('popstate', function (e) {
            $('#dNavToggle').prop("checked", false);
            //alert("URL Changed");
        });
        var observer = new MutationObserver(function (mutations) {
            mutations.forEach(function (mutation) {
                if (mutation.type == "childList") {
                    addNavToggle();
                }
            });
        });

        observer.observe(headerEL, {
            childList: true
        });
    })
});