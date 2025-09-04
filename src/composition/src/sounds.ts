import type { Audio } from "./audio";

export const house = (audio: Audio) =>
  audio.core.sound(`
    [~ ~ hh ~],
    [bd ~],
    [~ sd] / 2
  `);

export const drill = (audio: Audio) =>
  audio.core.sound(`
    [hh ~ ~ hh ~ ~ hh ~] / 2,
    [bd ~] / 8,
    [~ ~ rim ~ ~ ~ ~ rim] / 8
  `);
