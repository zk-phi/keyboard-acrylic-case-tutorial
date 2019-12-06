// ---- configurations

$fn = 100;

$key_pitch = 19.05;
$bezel = 5;
$kicad_grid = 0.297658;

$switch_positions = [
    [0.5, 2.5], [1.5, 2.5], [2.5, 2.5], [3.5, 2.5], [4.5, 2.5], [5.5, 2.5],
    [0.625, 1.5], [1.75, 1.5], [2.75, 1.5], [3.75, 1.5], [4.75, 1.5], [5.75, 1.5],
    [0.75, 0.5], [2, 0.5], [3, 0.5], [4, 0.5], [5, 0.5], [6, 0.5]
];

$screw_positions = [
    [0 * $key_pitch - $bezel / 2, 0 * $key_pitch - $bezel / 2],
    [0 * $key_pitch - $bezel / 2, 3 * $key_pitch + $bezel / 2],
    [6.5 * $key_pitch + $bezel / 2, 3 * $key_pitch + $bezel / 2],
    [6.5 * $key_pitch + $bezel / 2, 0 * $key_pitch - $bezel / 2]
];

module outer_shape () {
    translate([- $bezel, - $bezel])
        square([
            6.5 * $key_pitch + $bezel * 2,
            3.0 * $key_pitch + $bezel * 2
        ]);
}

module pcb_shape ($slop = 0) {
    polygon([
        [0 - $slop, 0 - $slop],
        [0 - $slop, 15.78 - $slop],
        [- 3.87 - $slop, 19.65 - $slop],
        [- 3.87 - $slop, 37.50 + $slop],
        [0 - $slop, 41.37 + $slop],
        [0 - $slop, 57.15 + $slop],
        [123.87 + $slop, 57.15 + $slop],
        [123.87 + $slop, 44.05 + $slop],
        [126.85 + $slop, 41.08 + $slop],
        [126.85 + $slop, 35.12 - $slop],
        [123.87 + $slop, 32.15 - $slop],
        [123.87 + $slop, 0 - $slop]
    ]);
}

module promicro ($slop = 0) {
    translate ([- 5 - $slop, 1.5 * $key_pitch - 17.86 / 2 - $slop])
        square([34.23 + $slop * 2, 17.86 + $slop * 2]);
}

module trrs ($slop = 0) {
    translate ([6.5 * $key_pitch - 8.93 - $slop, 38.1 - 5.95 / 2 - $slop])
        square([13.99 + $slop * 2, 5.95 + $slop * 2]);
}

module reset_pinhole () {
    translate ([119.06, 47.63])
        circle(d = 2.1);
}

// ----- plate models

module kadomaru (r) {
    offset (r = r) offset (r = - r) children();
}

module switch_holes () {
    for (pos = $switch_positions)
        translate (pos * $key_pitch)
            square([14, 14], center = true);
}

module screw_holes () {
    for (pos = $screw_positions)
        translate (pos)
          circle(d = 2.1);
}

module bottom_plate () {
    difference () {
        kadomaru(r = 4) outer_shape();
        screw_holes();
        reset_pinhole();
    }
}

module middle_frame () {
    difference () {
        kadomaru(r = 4) outer_shape();
        pcb_shape(0.6);
        screw_holes();
        promicro();
        trrs();
    }
}

module top_plate () {
    difference () {
        kadomaru(r = 4) outer_shape();
        switch_holes();
        screw_holes();
    }
}

module kicad_pcb () {
    translate([0, 3 * $key_pitch, 1.6]) import("../pcb/pcb.stl");
}

// ----

module laser_cut_model_3mm () {
    margin = 3;
    translate([$bezel + margin, 3 * $key_pitch + $bezel * 3 + margin * 2]) bottom_plate();
    translate([$bezel + margin, $bezel + margin]) top_plate();
}

module laser_cut_model_4mm () {
    margin = 3;
    translate([$bezel + margin, 3 * $key_pitch + $bezel * 3 + margin * 2]) middle_frame();
    translate([$bezel + margin, $bezel + margin]) middle_frame();
}

// ----

color([.3, .3, .3]) translate([0, 0, 11 - 3.4]) kicad_pcb();
translate([0, 0, 0]) linear_extrude(3) bottom_plate();
translate([0, 0, 3]) linear_extrude(8) middle_frame();
translate([0, 0, 11]) linear_extrude(3) top_plate();