import type Movie from "./movie.ts";

const decoder = new TextDecoder("utf-8");
const encoder = new TextEncoder();
const STOREFILE = "../store.json";

const writeAll = async(data : Uint8Array) => {
    const file = await Deno.open(STOREFILE, { write: true, create: true, truncate: true })
    for(let written = 0; written < data.length;) {
        written += Deno.writeSync(file.rid, data.subarray(written))
    }
    file.close()
}

const readAll = async() => {
    try {
        const data = await Deno.readFileSync(STOREFILE)
        if (data.length < 2) {
            return {}
        }
        return JSON.parse(decoder.decode(data))
    } catch (error) {
        if (error && error.name && error.name === "NotFound") {
            return {}
        }
        throw error
    }
}

export const newMovie = async (movie: Movie) => {
  movie.id = crypto.randomUUID();
  movie.watched = false;
  await setMovie(movie);
};

export const getMovieList = async () : Promise<Movie[]> => {
    try {
        const movies = await readAll();
        return Object.values(movies);
    } catch (error) {
        console.log('wat')
        console.log(error)
        Deno.exit(0);
    }
};

export const setMovie = async (movie: Movie) => {
  const movies = await readAll();
  movies[movie.id] = movie;
  const data = encoder.encode(JSON.stringify(movies));
  await writeAll(data);
};

export const deleteMovie = async (movie: Movie) => {
  const movies = await readAll();
  delete movies[movie.id];
  const data = encoder.encode(JSON.stringify(movies));
  await writeAll(data);
};
