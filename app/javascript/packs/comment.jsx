import React from 'react'
import ReactDOM from 'react-dom'
import 'whatwg-fetch'
import { Button, Modal } from 'react-bootstrap'

class CommentBase extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      comments: [],
      showResolved: false,
      showForm: false
    };
    this.getComments();
  }

  getComments() {
    fetch(this.props.data.url, {
      mode: 'cors',
      credentials: 'include'
    }).then((response) => {
      return response.json();
    }).then((json) => {
      this.setState({ comments: json });
    });
  }

  setComments = (comments, count) => {
    this.setState({ comments: comments });
    this.props.setCommentCount(count);
  }

  showForm = (show) => {
    this.setState({ showForm: show })
  }

  toggleShowResolved() {
    this.setState({ showResolved: !this.state.showResolved });
  }

  render() {
    return(
      <span>
        <div className='pull-right'>
          <label className='checkbox-inline mr-s'>
            <input type='checkbox' onChange={() => { this.toggleShowResolved() }} />
            {this.props.data.showResolved}
          </label>
        </div>
        <div className='mt-xl'>
          {
            this.state.comments.map((comment) => {
              return <Comment data={comment} buttons={JSON.parse(this.props.data.buttons)} key={`comment_${comment.id}`}
                              showResolved={this.state.showResolved} setComments={this.setComments} />
            })
          }
        </div>
        <div className='text-right'>
          { !this.state.showForm && (<Button onClick={() => { this.showForm(true) }}>{this.props.data.commentText}</Button>) }
        </div>
        <CommentForm show={this.state.showForm} parentId={null} key='comment_form_key_null'
                     showForm={this.showForm} setComments={this.setComments} />
      </span>
    );
  }
}

class Comment extends React.Component {
  constructor(props) {
    super(props);
    this.state = { showForm: false }
  }

  showForm = (show) => {
    this.setState({ showForm: show })
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
          { this.props.data.replyable && (<Button onClick={() => { this.showForm(true) }}>{this.props.buttons[0]}</Button>) }
          {
            this.props.data.resolve_url.length > 0 &&
              (<ResolveButton url={this.props.data.resolve_url} text={this.props.buttons[1]} setComments={this.props.setComments} />)
          }
        </div>
        <CommentForm show={this.state.showForm} parentId={this.props.data.id} key={`comment_form_key_${this.props.data.id}`}
                     showForm={this.showForm} setComments={this.props.setComments} />
        <div className='ml-xl'>
          {
            this.props.data.replies.length > 0 &&
              this.props.data.replies.map((reply) => {
                return <Comment data={reply} buttons={this.props.buttons} key={`comment_${reply.id}`}
                                showResolved={this.props.showResolved} setComments={this.props.setComments} />
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
      text: '',
      data: this.getData()
    };
  }

  componentWillReceiveProps(nextProps) {
    this.setState({ show: nextProps.show });
  }

  getData() {
    const data = document.querySelector('.comment-modal').dataset;
    return {
      content_id: data.contentId,
      current_user_id: data.currentUserId,
      url: data.url,
      buttons: JSON.parse(data.formButtons)
    };
  }

  onSubmit(e) {
    fetch(e.target.dataset.url, {
      mode: 'cors',
      credentials: 'include',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('.comment-modal').dataset.csrf
      },
      body: JSON.stringify({
        comment: {
          body: e.target.parentElement.previousSibling.value,
          content_id: e.target.dataset.contentId,
          user_id: e.target.dataset.userId,
          parent_id: e.target.dataset.parentId
        }
      })
    }).then((response) => {
      return response.json();
    }).then((json) => {
      document.querySelector(`#section-${json.id}-comment-icon`).innerHTML = '<i class="fa fa-commenting mr-s">';
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
        <textarea name='comment[body]' className='form-control mt-s mb-s' rows='3' onKeyUp={(e) => { this.onKeyUp(e) }}></textarea>
        <div className='text-right'>
          <Button disabled={!this.state.text} onClick={(e) => { this.onSubmit(e) }}
                  data-content-id={this.state.data.content_id} data-user-id={this.state.data.current_user_id}
                  data-parent-id={this.props.parentId} data-url={this.state.data.url}>
            {this.state.data.buttons[0]}
          </Button>
          <Button className='ml-s' onClick={() => { this.onCancel() }}>{this.state.data.buttons[1]}</Button>
        </div>
      </div>
    ) : null;
  }
}

class ResolveButton extends React.Component {
  render() {
    return <Button onClick={(e) => { this.onClick(e) }} data-url={this.props.url}>{this.props.text}</Button>;
  }

  onClick(e) {
    fetch(e.target.dataset.url, {
      mode: 'cors',
      credentials: 'include',
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('.comment-modal').dataset.csrf
      },
      body: JSON.stringify({
        comment: {
          resolve: true
        }
      })
    }).then((response) => {
      return response.json();
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
      style: props.buttonData.count > 0 ? 'primary' : 'default'
    };
  }

  handleClose() {
    this.setState({ show: false });
  }

  handleShow() {
    this.setState({ show: true });
  }

  setCommentCount = (count) => {
    this.setState({
      count: count,
      style: 'primary'
    });
  }

  render() {
    return (
      <span>
        <Button bsStyle={this.state.style} onClick={() => { this.handleShow() }}>
          {`${this.props.buttonData.text}${this.state.count > 0 ? ` (${this.state.count})` : ''}`}
        </Button>
        <Modal show={this.state.show} onHide={() => { this.handleClose() }}>
          <Modal.Header closeButton>
            <Modal.Title>{this.props.modalData.title}</Modal.Title>
          </Modal.Header>
          <Modal.Body>
            <CommentBase data={this.props.modalData} setCommentCount={this.setCommentCount} />
          </Modal.Body>
        </Modal>
      </span>
    );
  }
}

document.addEventListener('DOMContentLoaded', () => {
  const button = document.querySelector('.comment-button');
  if (button) {
    ReactDOM.render(
      <ShowCommentButton buttonData={button.dataset} modalData={document.querySelector('.comment-modal').dataset} />,
      button
    );
  }
});
