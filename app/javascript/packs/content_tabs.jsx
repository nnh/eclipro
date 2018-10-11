import React from 'react';
import { Tab, Nav, NavItem, Button } from 'react-bootstrap';
import I18n from './i18n';

class SectionLink extends React.Component {
  render() {
    const content = this.props.content;

    return (
      <div className={`${content.seq === 0 ? '' : 'child-list'} ${content.no_seq === this.props.noSeq ? 'active-section' : ''}`}>
        <a href={content.content_url} className={`section-link${content.editable ? '' : ' uneditable'}`}>
          {`${content.no === 0 ? '' : content.no_seq} ${content.title}`}
          <div className='pull-right'><i className={`fa fa-${content.status_icon}`} /></div>
          {content.comments_count.length && <div className='pull-right'><i className='fa fa-commenting mr-s' /></div>}
        </a>
      </div>
    );
  }
}

export default class ContentTabs extends React.Component {
  constructor(props) {
    super(props);
    this.state = { contents : props.contents };
    this.onClick = this.onClick.bind(this);
  }

  onClick() {
    if (confirm(I18n.t('js.content_tabs.copy_confirm'))) {
      this.props.onCopy();
    }
  }

  render() {
    return (
      <Tab.Container id='content-tab' defaultActiveKey='sections'>
        <div>
          <div className='clearfix'>
            <Nav bsStyle='tabs' className='container-fluid'>
              <NavItem eventKey='sections'>{I18n.t('js.content_tabs.sections')}</NavItem>
              <NavItem eventKey='instructions' disabled={this.props.instructions ? false : true}>{I18n.t('js.content_tabs.instructions')}</NavItem>
              <NavItem eventKey='example' disabled={this.props.example ? false : true}>{I18n.t('js.content_tabs.example')}</NavItem>
            </Nav>
          </div>
          <div>
            <Tab.Content>
              <Tab.Pane eventKey='example' className='menu menu-body mt-m'>
                {
                  this.props.example &&
                    <div>
                      <div dangerouslySetInnerHTML={{__html: this.props.example}}></div>
                      {
                        this.props.editable &&
                          (<div className='text-right'><Button onClick={this.onClick}>{I18n.t('js.content_tabs.copy')}</Button></div>)
                      }
                    </div>
                }
              </Tab.Pane>
              <Tab.Pane eventKey='instructions' className='menu menu-body mt-m'>
                <div dangerouslySetInnerHTML={{__html: this.props.instructions}}></div>
              </Tab.Pane>
              <Tab.Pane eventKey='sections' className='menu menu-body mt-m'>
                {this.state.contents.map((content) => <SectionLink key={`section-link-${content.id}`} content={content} noSeq={this.props.noSeq} />)}
              </Tab.Pane>
            </Tab.Content>
          </div>
        </div>
      </Tab.Container>
    );
  }
}
