const PALETTES = [
  ['#7C5CFC', '#5B3DF5'], // violet
  ['#FF6B57', '#FF3D71'], // coral-pink
  ['#22C1C3', '#1B7FE0'], // teal-blue
  ['#FDB44B', '#FF7E5F'], // amber-coral
  ['#43CBFF', '#9708CC'], // sky-purple
  ['#0BA360', '#3CBA92'], // forest-mint
  ['#F857A6', '#FF5858'], // rose-red
  ['#4E65FF', '#38B6FF']  // blue-cyan
];

function hashString(str) {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    hash = (hash << 5) - hash + str.charCodeAt(i);
    hash |= 0;
  }
  return Math.abs(hash);
}

function gradientFor(seed) {
  const [c1, c2] = PALETTES[hashString(seed || 'inkwell') % PALETTES.length];
  return `linear-gradient(150deg, ${c1}, ${c2})`;
}

// Initials for a story cover: up to 2 words from the title
function titleInitials(title) {
  const words = (title || '?').trim().split(/\s+/).filter(Boolean);
  return words.slice(0, 2).map(w => w[0].toUpperCase()).join('') || '?';
}

// Initials for a person avatar: first 2 chars of the username
function userInitials(username) {
  return (username || '?').slice(0, 2).toUpperCase();
}

module.exports = { gradientFor, titleInitials, userInitials };
