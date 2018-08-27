import 'whatwg-fetch'
import cheerio from 'cheerio'

export default function parsePubmed(pmid) {
  const pubmedUrl = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi';

  fetch(`${pubmedUrl}?db=pubmed&retmode=xml&id=${pmid}`, {
  }).then((response) => {
    return response.text();
  }).then((text) => {
    return new window.DOMParser().parseFromString(text, 'application/xml');
  }).then((data) => {
    console.log('111')
    const error = data.getElementsByTagName('ERROR');
    if (error.length) {
      alert(`Failed to get the data.\n${error[0].innerHTML}`);
      return;
    }

    const authorNames = [];
    const authors = data.getElementsByTagName('AuthorList')[0].getElementsByTagName('Author');
    for (let i = 0; i < authors.length; i++) {
      const author = authors[i];

      let lastName = '';
      const lastNameData = author.getElementsByTagName('LastName')[0];
      if (lastNameData) { lastName = lastNameData.innerHTML; }

      let initials = '';
      const initialsData = author.getElementsByTagName('Initials')[0];
      if (initialsData) { initials = initialsData.innerHTML; }

      authorNames.push([lastName, initials].filter((text) => text).join(' '));
    }

    let title = '';
    const articleTitle = data.getElementsByTagName('ArticleTitle')[0];
    if (articleTitle) { title = articleTitle.innerHTML; }

    let journal = '';
    const jornalData = data.getElementsByTagName('Journal')[0].getElementsByTagName('ISOAbbreviation')[0];
    if (jornalData) { journal = jornalData.innerHTML; }

    const date = ['Year', 'Month', 'Day'].map((m) => {
      const d = data.getElementsByTagName('PubDate')[0].getElementsByTagName(m)[0];
      if (d != undefined) return d.innerHTML;
    }).filter((f) => f).join(' ');

    let number = '';
    const issue = data.getElementsByTagName('Issue')[0];
    if (issue) { number = issue.innerHTML; }

    let page = '';
    const pagination = data.getElementsByTagName('Pagination')[0].getElementsByTagName('MedlinePgn')[0];
    if (pagination) { page = pagination.innerHTML; }

    let text = '';
    const volume = data.getElementsByTagName('Volume')[0];
    if (volume) { text = volume.innerHTML; }

    if (number) { text += `(${number})`; }
    if (page) { text += `:${page}.`; }

    return `${authorNames} ${title} ${journal}.${date};${text}`;
  }).catch((error) => {
    alert(`Failed to get the data.\n${error}`);
  });
}
