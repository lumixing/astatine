package game

import "core:fmt"

LogLevel :: enum {
    DEBUG, INFO, WARN, ERROR,
}

debug :: proc(args: ..any) {
    fmt.print("[DEBUG] ")
    fmt.println(..args)
}

info :: proc(str: string, args: ..any) {
    fmt.print("[INFO] ")
    fmt.printfln(str, ..args)
}

warn :: proc(str: string, args: ..any) {
    fmt.print("[WARN] ")
    fmt.printfln(str, ..args)
}

error :: proc(str: string, args: ..any) {
    fmt.print("[ERROR] ")
    fmt.printfln(str, ..args)
}
