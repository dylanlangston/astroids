const std = @import("std");
const raylib = @import("raylib");
const raymath = @import("raylib-math");
const raygui = @import("raygui");
const Shared = @import("../Shared.zig").Shared;
const AsteroidsViewModel = @import("../ViewModels/AsteroidsViewModel.zig").AsteroidsViewModel;

// Original Sauce 😋: https://github.com/raysan5/raylib-games/blob/master/classics/src/asteroids.c
// TODO: This code still needs ot be split into a ViewModel and updated to scale based on the current screenSize.

const vm: type = AsteroidsViewModel.GetVM();

fn DrawFunction() Shared.View.Views {
    raylib.clearBackground(Shared.Color.Tone.Dark);
    raylib.drawRectangleLinesEx(
        raylib.Rectangle.init(0, 0, vm.screenSize.x, vm.screenSize.y),
        5,
        Shared.Color.Green.Light,
    );

    vm.starScape.Draw(
        vm.screenSize.x,
        vm.screenSize.y,
        vm.player.position,
    );

    vm.Update();

    // Draw spaceship
    vm.player.Draw(vm.shipHeight, vm.PLAYER_BASE_SIZE);

    inline for (0..vm.MAX_ALIENS) |i| {
        vm.aliens[i].Draw();
    }

    // Draw meteors
    for (0..vm.MAX_SMALL_METEORS) |i| {
        if (i < vm.MAX_BIG_METEORS) {
            vm.bigMeteors[i].Draw(vm.player.position);
        }

        if (i < vm.MAX_MEDIUM_METEORS) {
            vm.mediumMeteors[i].Draw(vm.player.position);
        }

        vm.smallMeteors[i].Draw(vm.player.position);
    }

    // Draw shoot
    inline for (0..vm.PLAYER_MAX_SHOOTS) |i| {
        if (vm.shoot[i].active) vm.shoot[i].Draw();
    }

    // Draw alien shoot
    inline for (0..vm.ALIENS_MAX_SHOOTS) |i| {
        if (vm.alien_shoot[i].active) vm.alien_shoot[i].Draw();
    }

    return .AsteroidsView;
}

fn DrawWithCamera() Shared.View.Views {
    const camera = Shared.Camera.initScaledTargetCamera(
        vm.screenSize,
        3.5,
        raylib.Vector2.init(
            vm.player.position.x,
            vm.player.position.y - vm.shipHeight,
        ),
    );
    const result = camera.Draw(Shared.View.Views, &DrawFunction);

    // Draw Health
    raylib.drawRectangle(5, 5, 104, 16, Shared.Color.Gray.Dark.alpha(0.5));
    raylib.drawRectangle(
        8,
        8,
        @intFromFloat(@as(
            f32,
            @floatFromInt(vm.shieldLevel),
        ) / @as(
            f32,
            @floatFromInt(vm.MAX_SHIELD),
        ) * 100),
        10,
        Shared.Color.Red.Light.alpha(0.5),
    );

    if (vm.victory) Shared.Helpers.DrawTextCentered(
        "VICTORY",
        Shared.Color.Blue.Light,
        40,
        vm.screenSize.x,
        vm.screenSize.y / 2,
    );

    if (Shared.Input.Start_Pressed()) {
        return Shared.View.Pause(.AsteroidsView);
    }

    if (vm.shieldLevel == 0) {
        return Shared.View.GameOver();
    }

    return result;
}

pub const AsteroidsView = Shared.View.View{
    .Key = .AsteroidsView,
    .DrawRoutine = &DrawWithCamera,
    .VM = &AsteroidsViewModel,
};
