#!deno run --allow-read="../store.json"
import { getMovieList } from "../datastore.ts";

let movies : Movie[] = []
try {
  movies = await getMovieList();
} catch (error) {
  console.error(error);
  Deno.exit(1);
}

console.log(JSON.stringify(movies));
