#!deno run --allow-read=./store.json --allow-write=./store.json
import type Movie from "./movie.ts";
import { newMovie } from "./datastore.ts";

const buf = new Uint8Array(2048);
const n = await Deno.stdin.read(buf);
if (n == null) {
  Deno.exit(1);
}

const decoder = new TextDecoder("utf-8");
const movie: Movie = JSON.parse(decoder.decode(buf.subarray(0, n)));

try {
  newMovie(movie);
} catch (error) {
    console.error(error);
    Deno.exit(1);
}
