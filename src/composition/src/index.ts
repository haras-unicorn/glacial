import consola from "consola";
import { getAudio } from "./audio";
import { house } from "./sounds";

(async () => {
  const audio = await getAudio();
  consola.info("Playing... 🎵");
  const _ = audio.core;
  audio.repl.setCps(120 / 60);
  audio.repl.setPattern(_.stack(house(audio).bank("RolandTR909")), true);
})();
