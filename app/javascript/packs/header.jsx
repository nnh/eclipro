import React from 'react'
import { Navbar, Nav, NavItem, NavDropdown, MenuItem } from 'react-bootstrap'

class Header extends React.Component {
  render() {
    const signedIn = this.props.signedIn === 'true' ? true : false;

    return (
      <Navbar>
        <Navbar.Header>
          <Navbar.Brand>
            <a href='/'>eclipro</a>
          </Navbar.Brand>
        </Navbar.Header>
        <Nav>
          { signedIn && <NavItem eventKey={1} href={this.props.protocolUrl}>{I18n.t('js.header.view_protocols')}</NavItem> }
          { signedIn && <NavItem eventKey={2} href={this.props.newProtocolUrl}>{I18n.t('js.header.new_protocols')}</NavItem> }
          <NavItem eventKey={3} target="_blank"
            href="https://docs.google.com/document/d/e/2PACX-1vRC2HhdHbtB6M94VMRe9M9U_n05ZGKejh_cot9yc8S78bqX0NThv1_cluiUkBYLeNuiF9D2oLFr1Gs5/pub">
            {I18n.t('js.header.help')}
          </NavItem>
        </Nav>
        <Nav pullRight>
          {
            signedIn &&
              <NavDropdown eventKey={4} title={this.props.currentUser} id="dropdown-user">
                <MenuItem eventKey={4.1} href={this.props.editUrl}>{I18n.t('js.header.edit')}</MenuItem>
                <MenuItem eventKey={4.2} href={this.props.signOutUrl} data-method="delete">{I18n.t('js.header.sign_out')}</MenuItem>
              </NavDropdown>
          }
          {
            signedIn &&
              <NavDropdown eventKey={5} title={I18n.t('js.header.language')} id="dropdown-language">
                <MenuItem eventKey={5.1} href={`${this.props.languageUrl}?locale=ja`} data-method="patch">{I18n.t('js.header.japanese')}</MenuItem>
                <MenuItem eventKey={5.2} href={`${this.props.languageUrl}?locale=en`} data-method="patch">{I18n.t('js.header.english')}</MenuItem>
              </NavDropdown>
          }
          { !signedIn && <NavItem eventKey={6} href={this.props.signInUrl}>{I18n.t('js.header.sign_in')}</NavItem> }
        </Nav>
      </Navbar>
    );
  }
}

export default Header
