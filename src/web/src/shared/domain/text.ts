export type LineRange = { start: number; end: number } | null;

/**
 * Returns the 1-indexed start and end line numbers for a substring.
 * @param text string to file line numbers of
 * @param substring string to search
 * @returns start and end line numbers
 */
export const linesOf = (text: string, substring: string) => {
  let line = 0;
  let matchLine = 0;
  let matchedChars = 0;

  for (let i = 0; i < text.length; i++) {
    if (text[i] === substring[matchedChars]) {
      matchedChars++;
    } else {
      matchedChars = 0;
      matchLine = 0;
    }
    if (matchedChars === substring.length) {
      return {
        start: line - matchLine + 1,
        end: line + 1,
      };
    }
    if (text[i] === '\n') {
      line++;
      if (matchedChars > 0) {
        matchLine++;
      }
    }
  }

  return null;
};

/**
 * Using the parent nodes of an element, returns the lines of an XML node
 * within a document.
 * @param xml document to search
 * @param openedElements list of preceding, opened parent nodes
 * @param closedElements list of closing nodes to include in the matched pattern
 * @returns start and end lines
 */
export const linesOfXml = (
  xml: string,
  openedElements: string[],
  closedElements: string[],
) => {
  const regExp = createXmlMatchRegExp(openedElements, closedElements);
  const match = xml.match(regExp);
  if (match === null) {
    console.error(`XML match not found: ${regExp}`);
    return null;
  }
  const elementString = match[1];
  const lines = linesOf(xml, elementString);
  return lines;
};

const createXmlMatchRegExp = (
  openedElements: string[],
  closedElements: string[],
) => {
  const prefixElements = openedElements.slice(0, openedElements.length - 1);
  const matchOpenedElement = openedElements[openedElements.length - 1];

  const prefix = prefixElements.map(elem => `<${elem}[^>]*?>[^]*?`).join('');
  const suffix = closedElements
    .map(elem => `[^]+?(<\\/${elem}>|\\/>)`)
    .join('');

  const regExp = `(?:${prefix})(<${matchOpenedElement}${suffix})`;
  return new RegExp(regExp, 'u');
};