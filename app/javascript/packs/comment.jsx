import React from 'react'
import ReactDOM from 'react-dom'
import { Button, Modal } from 'react-bootstrap'
import { fetchByJSON } from './custom_fetch'

class Comment extends React.Component {
  constructor(props) {
    super(props);
    this.state = { showForm: false }
    this.onShowForm = this.onShowForm.bind(this);
  }

  onShowForm(show) {
    this.setState({ showForm: show });
  }

  render() {
    return(
      <div className={`comment p-m mt-s mb-s${this.props.data.resolve ? ' resolve-comment' : '' }${this.props.data.resolve && !this.props.showResolved ? ' hidden' : ''}`} >
        <div>
          <i className='fa fa-user mr-xs' />
          {this.props.data.user.name}
          <div className='pull-right'>
            <i className='fa fa-clock-o mr-xs' />
            {this.props.data.created_at}
          </div>
        </div>
        <div>{this.props.data.body}</div>
        <div className='text-right'>
          { this.props.data.replyable && (<Button onClick={this.onShowForm.bind(this, true)}>{I18n.t('js.comment.reply')}</Button>) }
          {
            this.props.data.resolve_url &&
              <ResolveButton url={this.props.data.resolve_url} onCommentsChanged={this.props.onCommentsChanged} />
          }
        </div>
        <CommentForm show={this.state.showForm} parentId={this.props.data.id} key={`comment_form_key_${this.props.data.id}`}
                     url={this.props.url} contentId={this.props.contentId} currentUserId={this.props.currentUserId}
                     onShowForm={this.onShowForm} onCommentsChanged={this.props.onCommentsChanged}
                     onCommentSubmitted={this.props.onCommentSubmitted} />
        <div className='ml-xl'>
          {
            this.props.data.replies.map((reply) =>
              <Comment data={reply} key={`comment_${reply.id}`}
                       showResolved={this.props.showResolved} onCommentsChanged={this.props.onCommentsChanged}
                       url={this.props.url} contentId={this.props.contentId} currentUserId={this.props.currentUserId}
                       onCommentSubmitted={this.props.onCommentSubmitted} />
            )
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
    fetchByJSON(this.props.url, 'POST', {
      comment: {
        body: this.state.text,
        content_id: this.props.contentId,
        user_id: this.props.currentUserId,
        parent_id: this.props.parentId
      }
    }).then((json) => {
      this.props.onCommentSubmitted(json);
      this.props.onCommentsChanged(json.comments, json.count);
      this.onCancel();
    });
  }

  onCancel() {
    this.setState({
      text: '',
      show: false
    });
    this.props.onShowForm(false);
  }

  onKeyUp(e) {
    this.setState({ text: e.target.value });
  }

  render() {
    return this.state.show ? (
      <div>
        <textarea name='comment[body]' className='form-control mt-s mb-s' rows='3' onKeyUp={this.onKeyUp} />
        <div className='text-right'>
          <Button disabled={!this.state.text} onClick={this.onSubmit}>{I18n.t('js.comment.create')}</Button>
          <Button className='ml-s' onClick={this.onCancel}>{I18n.t('js.comment.cancel')}</Button>
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
    return <Button onClick={this.onClick}>{I18n.t('js.comment.resolve')}</Button>;
  }

  onClick() {
    fetchByJSON(this.props.url, 'PUT', {
      comment: {
        resolve: true
      }
    }).then((json) => {
      this.props.onCommentsChanged(json.comments, json.count);
    });
  }
}

class ShowCommentButton extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      show: false,
      count: props.count,
      comments: [],
      showResolved: false,
      showForm: false
    };
    this.handleClose = this.handleClose.bind(this);
    this.handleShow = this.handleShow.bind(this);
    this.onCommentsChanged = this.onCommentsChanged.bind(this);
    this.onShowForm = this.onShowForm.bind(this);
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
    fetch(this.props.url, {
      mode: 'cors',
      credentials: 'include'
    }).then((response) => {
      return response.json();
    }).then((json) => {
      this.setState({ comments: json });
    });
  }

  onCommentsChanged(comments, count) {
    this.setState({
      comments: comments,
      count: count
    });
  }

  onShowForm(show) {
    this.setState({ showForm: show });
  }

  toggleShowResolved() {
    this.setState({ showResolved: !this.state.showResolved });
  }

  render() {
    return (
      <span>
        <Button bsStyle={this.state.count != 0 ? 'primary' : 'default'} onClick={this.handleShow}>
          {`${I18n.t('js.comment.comments')}${this.state.count > 0 ? ` (${this.state.count})` : ''}`}
        </Button>
        <Modal show={this.state.show} onHide={this.handleClose}>
          <Modal.Header closeButton>
            <Modal.Title>{I18n.t('js.comment.modal_title')}</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <div className='pull-right'>
              <label className='checkbox-inline mr-s'>
                <input type='checkbox' onChange={this.toggleShowResolved} />
                {I18n.t('js.comment.show_resolved')}
              </label>
            </div>
            <div className='mt-xl'>
              {
                this.state.comments.map((comment) =>
                  <Comment data={comment} key={`comment_${comment.id}`}
                           url={this.props.url} contentId={this.props.contentId} currentUserId={this.props.currentUserId}
                           showResolved={this.state.showResolved} onCommentsChanged={this.onCommentsChanged}
                           onCommentSubmitted={this.props.onCommentSubmitted} />
                )
              }
            </div>
            <div className='text-right'>
              { !this.state.showForm && (<Button onClick={this.onShowForm.bind(this, true)}>{I18n.t('js.comment.comment')}</Button>) }
            </div>
            <CommentForm show={this.state.showForm} parentId={null} key='comment_form_key_null'
                         onShowForm={this.onShowForm} onCommentsChanged={this.onCommentsChanged}
                         url={this.props.url} contentId={this.props.contentId} currentUserId={this.props.currentUserId}
                         onCommentSubmitted={this.props.onCommentSubmitted} />
          </Modal.Body>
        </Modal>
      </span>
    );
  }
}

export { ShowCommentButton }
