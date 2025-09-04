import consola from "consola";

const GLACIAL_AUDIO_HANDLE = Symbol.for("glacial-audio");

export type Audio = {
  core: typeof import("@strudel/core");
  web: typeof import("@strudel/webaudio");
  mini: typeof import("@strudel/mini");
  repl: Repl;
};

export const getAudio = async () => {
  // biome-ignore lint/suspicious/noExplicitAny: we need to put it somewhere
  const g = globalThis as unknown as any;

  if (g[GLACIAL_AUDIO_HANDLE] != null) {
    return g[GLACIAL_AUDIO_HANDLE] as Audio;
  }

  consola.info("Making the strudel...");
  const audio = await initAudio();
  consola.info("The strudel hath been made :3 🍰");

  g[GLACIAL_AUDIO_HANDLE] = audio;

  return audio;
};

const initAudio = async () => {
  const core = await import("@strudel/core");
  const web = await import("@strudel/webaudio");
  const mini = await import("@strudel/mini");

  await web.initAudio();
  const repl = web.webaudioRepl();
  await mini.miniAllStrings();

  await web.registerSynthSounds();

  const ds = "https://raw.githubusercontent.com/felixroos/dough-samples/main/";
  await web.samples(`${ds}/tidal-drum-machines.json`);
  await web.samples(`${ds}/piano.json`);

  const strudel: Audio = { core, web, mini, repl };

  return strudel;
};
