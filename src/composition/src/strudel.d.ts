type Pattern = {
  bank: (bank: string) => Pattern;
  sound: (sound: string) => Pattern;
};

type Repl = {
  setPattern: (pattern: unknown, now: boolean) => undefined;
  setCps: (cps: number) => undefined;
};

declare module "@strudel/core" {
  const ns: {
    stack: (...patterns: Pattern[]) => Pattern;
    sound: (sound: string) => Pattern;
    note: (note: string) => Pattern;
  };
  export = ns;
}

declare module "@strudel/mini" {
  const ns: { miniAllStrings: () => PromiseLike<undefined> };
  export = ns;
}

declare module "@strudel/webaudio" {
  const ns: {
    initAudio: () => PromiseLike<undefined>;

    webaudioRepl: () => Repl;

    registerSynthSounds: () => PromiseLike<undefined>;
    samples: (url: string) => PromiseLike<undefined>;
  };
  export = ns;
}
