
export def cache [remote: string]: string -> nothing {
    let path = $in
    if not ($path | path exists) {
        git clone --bare $remote $path
    }
}
