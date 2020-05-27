
import { parse as orig_parse } from '../../build/parser';

function parse(s: string) {
  return orig_parse(s);
}

export { parse };
