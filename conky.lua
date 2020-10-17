require 'cairo'

colors = {
    color1=0xA9A9A9,
    color2=0x616161,
    color3=0x313131,
    green=0x00FF00,
    red=0xFF0000,
    yellow=0xFFFF00,
}

x = 5

-- converts color in hexa to decimal
function rgb_to_r_g_b(color, alpha)
    if alpha == nil then
        alpha = 1.0
    end
    return ((color / 0x10000) % 0x100) / 255., ((color / 0x100) % 0x100) / 255., (color % 0x100) / 255., alpha
end


function conky_main()
    local y = 705
    local cs = cairo_xlib_surface_create(
        conky_window.display,
        conky_window.drawable,
        conky_window.visual,
        conky_window.width,
        conky_window.height)
    local display = cairo_create(cs)
    normal_font(display)
    cairo_set_font_size(display, 12)
    cairo_set_source_rgba(display, rgb_to_r_g_b(colors.color1))
    if show_backup_log(display, "system", "/var/log/duplicati-system.log", y) then
        y = y + 20
    end
    show_backup_log(display, "klaatu", "/var/log/duplicati-klaatu.log", y)
end

function normal_font(display)
    cairo_select_font_face(display, "Ubuntu", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
end

function monospace_font(display)
    cairo_select_font_face(display, "mono", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
end

function color_text(display, text, color, alpha)
    cairo_set_source_rgba(display, rgb_to_r_g_b(color, alpha))
    cairo_show_text(display, text)
    cairo_set_source_rgba(display, rgb_to_r_g_b(colors.color1));
end

function show_log_name(display, log_name)
    log_name = string.sub(log_name, 0, 8)
    monospace_font(display)
    color_text(display, "[" .. log_name .. "]", colors.color2)
    for i = string.len(log_name), 8, 1 do
        cairo_show_text(display, " ")
    end
    normal_font(display)
end

function show_backup_log(display, log_name, filename, y)
    local f = io.open(filename)
    if f ~= nil then
        cairo_move_to(display, x, y)
        local text = f:read()
        show_log_name(display, log_name)
        if string.find(text, "Success") then
            cairo_show_text(display, string.gsub(text, "Success", ""))
            color_text(display, "Success", colors.green, 0.8)
        elseif string.find(text, "Warning") then
            cairo_show_text(display, string.gsub(text, "Warning", ""))
            color_text(display, "Warning", colors.yellow, 0.8)
        elseif string.find(text, "Error") then
            cairo_show_text(display, string.gsub(text, "Error", ""))
            color_text(display, "Error", colors.red, 0.8)
        elseif string.find(text, "Fatal") then
            cairo_show_text(display, string.gsub(text, "Fatal", ""))
            color_text(display, "Fatal", colors.red, 0.8)
        else
            cairo_show_text(display, text)
        end
        f:close()
        return true
    end
    f:close()
    return false
end
