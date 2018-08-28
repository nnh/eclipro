import 'whatwg-fetch'
import cheerio from 'cheerio'

export default async function insertPubmed(pmid) {
  try {
    const response = await fetch(`https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=xml&id=${pmid}`);
    const responseText = await response.text();
    const data = cheerio.load(responseText);

    const error = data('eFetchResult > ERROR');
    if (error.length) {
      return { error: error.text() };
    }

    const authorNames = [];
    const authors = data('AuthorList > Author');
    authors.each((i, author) => {
      const authorData = cheerio.load(author);
      authorNames.push([authorData('LastName').text(), authorData('Initials').text()].filter((v) => v).join(' '));
    });

    const title = data('ArticleTitle').text();

    const journal = data('ISOAbbreviation').text();

    const tagName =  data('PubDate').length ? 'PubDate' : 'PubMedPubDate[PubStatus="pubmed"]';
    const year = data(`${tagName} > Year`).text();
    let month = data(`${tagName} > Month`).text();
    if (!isNaN(parseInt(month))) {
      const monthText = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      month = monthText[parseInt(month - 1)];
    }
    const date = [year, month].filter((v) => v).join(' ');

    let text = data('Volume').text();
    const issue = data('Issue').text();
    if (issue.length) { text += `(${issue})`; }
    const page = data('MedlinePgn').text();
    if (page.length) { text += `:${page}.`; }

    return { content: `${authorNames.join(', ')} ${title} ${journal}.${date};${text}` };
  } catch (error) {
    return { error: error };
  }
}
