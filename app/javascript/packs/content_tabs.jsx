import React from 'react'
import { Tab, Nav, NavItem, Button } from 'react-bootstrap'

class SectionLink extends React.Component {
  render() {
    const content = this.props.content;

    return (
      <div className={`${content.seq === 0 ? '' : 'child-list'} ${content.no_seq === this.props.noSeq ? 'active-section' : ''}`}>
        <a href={content.content_url} className={`section-link${content.editable ? '' : ' uneditable'}`}>
          {`${content.no === 0 ? '' : content.no_seq} ${content.title}`}
          <div className='pull-right'><i className={`fa fa-${content.status_icon}`} /></div>
          {content.comments_count && <div className='pull-right'><i className='fa fa-commenting mr-s' /></div>}
        </a>
      </div>
    );
  }
}

export default class ContentTabs extends React.Component {
  constructor(props) {
    super(props);
    this.state = { contents : props.contents }
    this.onClick = this.onClick.bind(this);
  }

  onClick(e) {
    if (confirm(this.props.copyConfirm)) {
      this.props.onCopy(e);
    }
  }

  render() {
    return (
      <Tab.Container id='content-tab' defaultActiveKey='sections'>
        <div>
          <div className='clearfix'>
            <Nav bsStyle='tabs' className='container-fluid'>
              <NavItem eventKey='sections'>{this.props.sectionsText}</NavItem>
              <NavItem eventKey='instructions' disabled={this.props.instructions ? false : true}>{this.props.instructionsText}</NavItem>
              <NavItem eventKey='example' disabled={this.props.example ? false : true}>{this.props.exampleText}</NavItem>
            </Nav>
          </div>
          <div>
            <Tab.Content>
              <Tab.Pane eventKey='example' className='menu menu-body mt-m'>
                {
                  this.props.example &&
                    <div>
                      <div dangerouslySetInnerHTML={{__html: this.props.example}}></div>
                      <div className='text-right'>
                        <Button onClick={this.onClick}>{this.props.copyText}</Button>
                      </div>
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
