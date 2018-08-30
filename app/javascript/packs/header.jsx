import React from 'react'
import { Navbar, Nav, NavItem, NavDropdown, MenuItem } from 'react-bootstrap'

class Header extends React.Component {
  render() {
    const signedIn = this.props.signedIn === 'true' ? true : false;

    return (
      <Navbar>
        <Navbar.Header>
          <Navbar.Brand>
            <a href={this.props.rootUrl}>eclipro</a>
          </Navbar.Brand>
        </Navbar.Header>
        <Nav>
          { signedIn && <NavItem eventKey={1} href={this.props.protocolUrl}>{this.props.protocolText}</NavItem> }
          { signedIn && <NavItem eventKey={2} href={this.props.newProtocolUrl}>{this.props.newProtocolText}</NavItem> }
          <NavItem eventKey={3} target="_blank"
            href="https://docs.google.com/document/d/e/2PACX-1vRC2HhdHbtB6M94VMRe9M9U_n05ZGKejh_cot9yc8S78bqX0NThv1_cluiUkBYLeNuiF9D2oLFr1Gs5/pub">
            {this.props.helpText}
          </NavItem>
        </Nav>
        <Nav pullRight>
          {
            signedIn &&
              <NavDropdown eventKey={4} title={this.props.currentUserText} id="dropdown-user">
                <MenuItem eventKey={4.1} href={this.props.editUrl}>{this.props.editText}</MenuItem>
                <MenuItem eventKey={4.2} href={this.props.signOutUrl} data-method="delete">{this.props.signOutText}</MenuItem>
              </NavDropdown>
          }
          {
            signedIn &&
              <NavDropdown eventKey={5} title={this.props.languageText} id="dropdown-language">
                <MenuItem eventKey={5.1} href={`${this.props.languageUrl}?locale=ja`} data-method="patch">{this.props.japaneseText}</MenuItem>
                <MenuItem eventKey={5.2} href={`${this.props.languageUrl}?locale=en`} data-method="patch">{this.props.englishText}</MenuItem>
              </NavDropdown>
          }
          { !signedIn && <NavItem eventKey={6} href={this.props.signInUrl}>{this.props.signInText}</NavItem> }
        </Nav>
      </Navbar>
    );
  }
}

export default Header
