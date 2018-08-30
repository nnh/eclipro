import React from 'react'
import { Tab, Nav, NavItem, Button } from 'react-bootstrap'
import tinyMCE from 'tinymce'

class SectionLink extends React.Component {
  render() {
    const content = this.props.content;

    return (
      <div className={`${content.seq === 0 ? '' : 'child-list'} ${content.no_seq === this.props.noSeq ? 'active-section' : ''}`}>
        <a href={content.content_url} className={`section-link${content.editable ? '' : ' uneditable'}`}>
          {`${content.no === 0 ? '' : content.no_seq} ${content.title}`}
          <div className='pull-right' id={`section-${content.no_seq.replace('.', '-')}-icon`}>
            <i className={`fa fa-${content.status_icon}`} />
          </div>
          <div className='pull-right' id={`section-${content.no_seq.replace('.', '-')}-comment-icon`}>
            {content.comments_count.length && <i className='fa fa-commenting mr-s' />}
          </div>
        </a>
      </div>
    );
  }
}

export default class ContentTabs extends React.Component {
  constructor(props) {
    super(props);
    this.onClick = this.onClick.bind(this);
  }

  onClick(e) {
    if (confirm(this.props.copyConfirm)) {
      const form = tinyMCE.get('form-tinymce');
      form.setContent(`<div contenteditable="true">${e.target.parentElement.previousSibling.innerHTML}</div>`);
      form.execCommand('changeText');
    }
  }

  render() {
    return (
      <Tab.Container id='content-tab' defaultActiveKey='sections'>
        <div>
          <div className='clearfix'>
            <Nav bsStyle='pills' className='pull-right'>
              <NavItem eventKey='example' className='nav-border' disabled={this.props.example ? false : true}>{this.props.exampleText}</NavItem>
              <NavItem eventKey='instructions' className='nav-border' disabled={this.props.instructions ? false : true}>{this.props.instructionsText}</NavItem>
              <NavItem eventKey='sections' className='nav-border'>{this.props.sectionsText}</NavItem>
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
                {this.props.contents.map((content) => <SectionLink key={`section-link-${content.id}`} content={content} noSeq={this.props.noSeq} />)}
              </Tab.Pane>
            </Tab.Content>
          </div>
        </div>
      </Tab.Container>
    );
  }
}
