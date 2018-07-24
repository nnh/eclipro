import React from 'react'
import ReactDOM from 'react-dom'
import 'whatwg-fetch'
import { Button, Modal } from 'react-bootstrap'

class CommentBase extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      comments: [],
      showResolved: false
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
    this.resetForm();
  }

  addCommentForm() {
    this.resetForm();
    ReactDOM.render(
      <CommentForm parentId={null} node={'.new-comment-form'} setComments={this.setComments} resetForm={this.resetForm} />,
      document.querySelector('.new-comment-form')
    );

    document.querySelector('.new-comment-form').classList.remove('hidden');
    document.querySelector('.add-comment-form').classList.add('hidden');
  }

  resetForm() {
    Array.from(document.querySelectorAll('.reply-form, .new-comment-form'), (element) => { ReactDOM.unmountComponentAtNode(element); });
    document.querySelector('.new-comment-form').classList.add('hidden');
    document.querySelector('.add-comment-form').classList.remove('hidden');
  }

  toggleShowResolved() {
    this.setState({ showResolved: !this.state.showResolved });
  }

  render() {
    return(
      <span>
        <div className='pull-right'>
          <label className='checkbox-inline mr-s'>
            <input type='checkbox' className='show-resolved' onChange={() => { this.toggleShowResolved() }} />
            {this.props.data.showResolved}
          </label>
        </div>
        <div className='mt-xl comment-index'>
          {
            this.state.comments.map((comment) => {
              return <Comment data={comment} buttons={JSON.parse(this.props.data.buttons)}
                              key={`comment_${comment.id}`} showResolved={this.state.showResolved}
                              setComments={this.setComments} resetForm={this.resetForm} />
            })
          }
        </div>
        <div className='text-right add-comment-form'>
          <Button onClick={() => { this.addCommentForm() }}>{this.props.data.commentText}</Button>
        </div>
        <div className='new-comment-form hidden'></div>
      </span>
    );
  }
}

class Comment extends React.Component {
  constructor(props) {
    super(props);
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
          {
            this.props.data.replyable ?
              <ReplyButton text={this.props.buttons[0]} parentId={this.props.data.id}
                           setComments={this.props.setComments} resetForm={this.props.resetForm} /> : null
          }
          {
            this.props.data.resolve_url.length > 0 ?
              <ResolveButton url={this.props.data.resolve_url} text={this.props.buttons[1]} setComments={this.props.setComments} /> : null
          }
        </div>
        <div className='ml-xl'>
          {
            this.props.data.replies.length > 0 ?
              this.props.data.replies.map((reply) => {
                return <Comment data={reply} buttons={this.props.buttons} key={`comment_${reply.id}`}
                                showResolved={this.props.showResolved} setComments={this.props.setComments} resetForm={this.props.resetForm} />
              }) : null
          }
        </div>
        <div className='reply-form' id={`reply-${this.props.data.id}`}></div>
      </div>
    );
  }
}

class CommentForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      text: '',
      data: this.getData()
    };
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
    });
  }

  onCancel(e) {
    this.props.resetForm();
  }

  onKeyUp(e) {
    this.setState({ text: e.target.value });
  }

  render() {
    return (
      <div className='comment-form'>
        <textarea name='comment[body]' className='form-control mt-s mb-s' rows='3' onKeyUp={(e) => { this.onKeyUp(e) }}></textarea>
        <div className='text-right'>
          <Button disabled={!this.state.text} onClick={(e) => { this.onSubmit(e) }}
                  data-content-id={this.state.data.content_id} data-user-id={this.state.data.current_user_id}
                  data-parent-id={this.props.parentId} data-url={this.state.data.url}>
            {this.state.data.buttons[0]}
          </Button>
          <Button className='ml-s' onClick={(e) => { this.onCancel(e) }}>{this.state.data.buttons[1]}</Button>
        </div>
      </div>
    );
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

class ReplyButton extends React.Component {
  render() {
    return <Button onClick={(e) => { this.onClick(e) }}>{this.props.text}</Button>;
  }

  onClick(e) {
    this.props.resetForm();
    ReactDOM.render(
      <CommentForm parentId={this.props.parentId} node={`#reply-${this.props.parentId}`}
                   setComments={this.props.setComments} resetForm={this.props.resetForm} />,
      document.querySelector(`#reply-${this.props.parentId}`)
    );
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
        <Button className='show-comments-button' bsStyle={this.state.style} onClick={() => { this.handleShow() }}>
          {`${this.props.buttonData.text}${this.state.count > 0 ? ` (${this.state.count})` : ''}`}
        </Button>
        <Modal show={this.state.show} onHide={(e) => { this.handleClose(e) }}>
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
