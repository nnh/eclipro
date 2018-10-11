window.onload = () => {
  const vars = {};
  const locations = document.location.search.substring(1).split('&');
  for (const i in locations) {
    const location = locations[i].split('=', 2);
    vars[location[0]] = decodeURIComponent(location[1]);
  }
  const classNames = ['frompage', 'topage', 'page', 'webpage', 'section', 'subsection', 'subsubsection'];
  for (const i in classNames) {
    const elements = document.getElementsByClassName(classNames[i]);
    for (let j = 0; j < elements.length; ++j)
      elements[j].textContent = vars[classNames[i]];
  }
};
