import React from 'react'
import ReactDOM from 'react-dom'
import 'whatwg-fetch'
import { Button, Modal } from 'react-bootstrap'
import fetchByJSON from './fetch_by_json'

class Comment extends React.Component {
  constructor(props) {
    super(props);
    this.state = { showForm: false }
    this.showForm = this.showForm.bind(this);
  }

  showForm(show) {
    this.setState({ showForm: show });
  }

  render() {
    return(
      <div className={`comment p-m mt-s mb-s${this.props.data.resolve ? ' resolve-comment' : '' }${this.props.data.resolve && !this.props.showResolved ? ' hidden' : ''}`} >
        <div>
          <i className='fa fa-user mr-xs'></i>
          {this.props.data.user.name}
          <div className='pull-right'>
            <i className='fa fa-clock-o mr-xs'></i>
            {this.props.data.created_at}
          </div>
        </div>
        <div>{this.props.data.body}</div>
        <div className='text-right'>
          { this.props.data.replyable && (<Button onClick={this.showForm.bind(this, true)}>{this.props.modalData.buttons[0]}</Button>) }
          {
            this.props.data.resolve_url &&
              <ResolveButton url={this.props.data.resolve_url} text={this.props.modalData.buttons[1]} setComments={this.props.setComments} />
          }
        </div>
        <CommentForm show={this.state.showForm} parentId={this.props.data.id} key={`comment_form_key_${this.props.data.id}`}
                     showForm={this.showForm} setComments={this.props.setComments}
                     modalData={this.props.modalData} onCommentSubmitted={this.props.onCommentSubmitted} />
        <div className='ml-xl'>
          {
            this.props.data.replies &&
              this.props.data.replies.map((reply) => {
                return <Comment data={reply} key={`comment_${reply.id}`}
                                showResolved={this.props.showResolved} setComments={this.props.setComments}
                                modalData={this.props.modalData} onCommentSubmitted={this.props.onCommentSubmitted} />
              })
          }
        </div>
      </div>
    );
  }
}

class CommentForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      show: props.show ? true : false,
      text: ''
    };

    this.onSubmit = this.onSubmit.bind(this);
    this.onCancel = this.onCancel.bind(this);
    this.onKeyUp = this.onKeyUp.bind(this);
  }

  componentWillReceiveProps(nextProps) {
    this.setState({ show: nextProps.show });
  }

  onSubmit() {
    fetchByJSON(this.props.modalData.url, 'POST', {
      comment: {
        body: this.state.text,
        content_id: this.props.modalData.contentId,
        user_id: this.props.modalData.currentUserId,
        parent_id: this.props.parentId
      }
    }).then((json) => {
      this.props.onCommentSubmitted(json);
      this.props.setComments(json.comments, json.count);
      this.onCancel();
    });
  }

  onCancel() {
    this.setState({
      text: '',
      show: false
    });
    this.props.showForm(false);
  }

  onKeyUp(e) {
    this.setState({ text: e.target.value });
  }

  render() {
    return this.state.show ? (
      <div>
        <textarea name='comment[body]' className='form-control mt-s mb-s' rows='3' onKeyUp={this.onKeyUp}></textarea>
        <div className='text-right'>
          <Button disabled={!this.state.text} onClick={this.onSubmit}>
            {this.props.modalData.formButtons[0]}
          </Button>
          <Button className='ml-s' onClick={this.onCancel}>{this.props.modalData.formButtons[1]}</Button>
        </div>
      </div>
    ) : null;
  }
}

class ResolveButton extends React.Component {
  constructor(props) {
    super(props);
    this.onClick = this.onClick.bind(this);
  }

  render() {
    return <Button onClick={this.onClick}>{this.props.text}</Button>;
  }

  onClick() {
    fetchByJSON(this.props.url, 'PUT', {
      comment: {
        resolve: true
      }
    }).then((json) => {
      this.props.setComments(json.comments, json.count);
    });
  }
}

class ShowCommentButton extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      show: false,
      count: props.buttonData.count,
      comments: [],
      showResolved: false,
      showForm: false
    };
    this.handleClose = this.handleClose.bind(this);
    this.handleShow = this.handleShow.bind(this);
    this.setComments = this.setComments.bind(this);
    this.showForm = this.showForm.bind(this);
    this.toggleShowResolved = this.toggleShowResolved.bind(this);

    this.getComments();
  }

  handleClose() {
    this.setState({ show: false });
  }

  handleShow() {
    this.setState({ show: true });
  }

  getComments() {
    fetch(this.props.modalData.url, {
      mode: 'cors',
      credentials: 'include'
    }).then((response) => {
      return response.json();
    }).then((json) => {
      this.setState({ comments: json });
    });
  }

  setComments(comments, count) {
    this.setState({
      comments: comments,
      count: count
    });
  }

  showForm(show) {
    this.setState({ showForm: show });
  }

  toggleShowResolved() {
    this.setState({ showResolved: !this.state.showResolved });
  }

  render() {
    return (
      <span>
        <Button bsStyle={this.state.count != 0 ? 'primary' : 'default'} onClick={this.handleShow}>
          {`${this.props.buttonData.text}${this.state.count > 0 ? ` (${this.state.count})` : ''}`}
        </Button>
        <Modal show={this.state.show} onHide={this.handleClose}>
          <Modal.Header closeButton>
            <Modal.Title>{this.props.modalData.title}</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <div className='pull-right'>
              <label className='checkbox-inline mr-s'>
                <input type='checkbox' onChange={this.toggleShowResolved} />
                {this.props.modalData.showResolved}
              </label>
            </div>
            <div className='mt-xl'>
              {
                this.state.comments.map((comment) => {
                  return <Comment data={comment} key={`comment_${comment.id}`}
                                  showResolved={this.state.showResolved} setComments={this.setComments}
                                  modalData={this.props.modalData} onCommentSubmitted={this.props.onCommentSubmitted} />
                })
              }
            </div>
            <div className='text-right'>
              { !this.state.showForm && (<Button onClick={this.showForm.bind(this, true)}>{this.props.modalData.commentText}</Button>) }
            </div>
            <CommentForm show={this.state.showForm} parentId={null} key='comment_form_key_null'
                         showForm={this.showForm} setComments={this.setComments}
                         modalData={this.props.modalData} onCommentSubmitted={this.props.onCommentSubmitted} />
          </Modal.Body>
        </Modal>
      </span>
    );
  }
}

export { ShowCommentButton }
