function doSubmit() {
    const text = document.querySelector("textarea")
    fetch("bloom-create.exe", {
        method: "POST",
        body: text.value,
    })
    .then(r => r.blob())
    .then(b => {
        const u = window.URL.createObjectURL(b);
        window.location.assign(u);
    })
}