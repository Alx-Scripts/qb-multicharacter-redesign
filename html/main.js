
    function showoptions(id) {
        var option = document.getElementById(id);

        option.style.left = "90px"
    }

    function hideoptions(id) {
        var option = document.getElementById(id);

        option.style.left = "-260px"
    }

    function hidemainscreen() {
        var all = document.getElementById("all")

        all.style.opacity = 0

        setTimeout(() => {
            all.style.display = "none"
        }, 400);
    }

    function showwindow(id) {
        var option = document.getElementById(id);

        option.style.display = "flex"

        setTimeout(() => {
            option.style.opacity = "1"
        }, 1000);
    }

    function hidewindow(id) {
        var option = document.getElementById(id);

        
        option.style.opacity = "0"

        setTimeout(() => {
            option.style.display = "none"
        }, 1000);
    }


