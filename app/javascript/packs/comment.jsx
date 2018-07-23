import React from 'react'
import ReactDOM from 'react-dom'
import 'whatwg-fetch'
import Modal from './modal'

class CommentBase extends React.Component {
  render() {
    return(
      <div>
        <div className='pull-right negative-mt-xl'>
          <label className='checkbox-inline mr-s'>
            <input type='checkbox' className='show-resolved' onChange={() => { this.showResolved() }} />
            {this.props.showResolved}
          </label>
        </div>
        <div className='mt-xl comment-index'></div>
        <div className='text-right add-comment-form'>
          <button name='button' type='button' className='btn btn-default' onClick={() => { this.addComment() }}>
            {this.props.button}
          </button>
        </div>
        <div className='new-comment-form hidden'></div>
      </div>
    );
  }

  showResolved() {
    changeResolvedComment();
  }

  addComment() {
    resetForm();
    ReactDOM.render(
      <CommentForm data={createData()} />,
      document.querySelector('.new-comment-form')
    );

    document.querySelector('.new-comment-form').classList.remove('hidden');
    document.querySelector('.add-comment-form').classList.add('hidden');
  }
}

class CommentIndex extends React.Component {
  render() {
    const body = this.props.data.map((data) => {
      return(
        <div className={`comment p-m mt-s mb-s${data.resolve ? ' resolve-comment' : '' }`} key={`comment_${data.id}`} >
          <div>
            <i className='fa fa-user mr-xs'></i>
            {data.user.name}
            <div className='pull-right'>
              <i className='fa fa-clock-o mr-xs'></i>
              {data.created_at}
            </div>
          </div>
          <div>{data.body}</div>
          <div className='text-right'>
            {data.replyable ? <ReplyButton parentId={data.id} text={this.props.buttons[0]} /> : null}
            {data.resolve_url.length > 0 ? <ResolveButton url={data.resolve_url} text={this.props.buttons[1]} /> : null}
          </div>
          <div className='ml-xl'>
            {data.replies.length > 0 ? <CommentIndex data={data.replies} buttons={this.props.buttons} /> : null}
          </div>
          <div className='reply-form' id={`reply-${data.id}`}></div>
        </div>
      );
    });

    return body;
  }
}

class CommentForm extends React.Component {
  constructor(props) {
    super(props);
    this.state = { text: '' };
  }

  render() {
    return (
      <div>
        <textarea name='comment[body]' className='form-control mt-s mb-s' rows='3' onKeyUp={(e) => { this.onKeyUp(e) }}></textarea>
        <div className='text-right'>
          <button className='btn btn-default' disabled={!this.state.text} onClick={(e) => { this.onSubmit(e) }}
                  data-content-id={this.props.data.content_id} data-user-id={this.props.data.current_user_id}
                  data-parent-id={this.props.data.parent_id} data-url={this.props.data.url}>
            {this.props.data.buttons[0]}
          </button>
          <button className='btn btn-default ml-s' onClick={(e) => { this.onCancel(e) }}>{this.props.data.buttons[1]}</button>
        </div>
      </div>
    );
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

      const commentButton = document.querySelector('.show-comments-button');
      commentButton.innerHTML = `${commentButton.dataset.text} (${json.count})`;
      commentButton.classList.remove('btn-default');
      commentButton.classList.add('btn-primary');

      ReactDOM.render(
        <CommentIndex data={json.comments} buttons={JSON.parse(document.querySelector('.comment-modal').dataset.buttons)} />,
        document.querySelector('.comment-index')
      );
      resetForm();
      changeResolvedComment();
    });
  }

  onCancel(e) {
    resetForm();
  }

  onKeyUp(e) {
    this.setState({ text: e.target.value });
  }
}

class ResolveButton extends React.Component {
  render() {
    return (
      <button className='btn btn-default' onClick={(e) => { this.onClick(e) }} data-url={this.props.url}>
        {this.props.text}
      </button>
    );
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
      ReactDOM.render(
        <CommentIndex data={json} buttons={JSON.parse(document.querySelector('.comment-modal').dataset.buttons)} />,
        document.querySelector('.comment-index')
      );
      resetForm();
      changeResolvedComment();
    });
  }
}

class ReplyButton extends React.Component {
  render() {
    return (
      <button className='btn btn-default' onClick={(e) => { this.onClick(e) }} data-parent-id={this.props.parentId}>
        {this.props.text}
      </button>
    );
  }

  onClick(e) {
    resetForm();
    const parentId = e.target.dataset.parentId;
    ReactDOM.render(
      <CommentForm data={createData(parentId)} />,
      document.querySelector(`#reply-${parentId}`)
    );
  }
}

function resetForm() {
  Array.from(document.querySelectorAll('.reply-form, .new-comment-form'), (element) => { ReactDOM.unmountComponentAtNode(element); });
  document.querySelector('.new-comment-form').classList.add('hidden');
  document.querySelector('.add-comment-form').classList.remove('hidden');
}

function changeResolvedComment() {
  if (document.querySelector('.show-resolved').checked) {
    Array.from(document.querySelectorAll('.resolve-comment'), (element) => { element.classList.remove('hidden') });
  } else {
    Array.from(document.querySelectorAll('.resolve-comment'), (element) => { element.classList.add('hidden') });
  }
}

function createData(parentId = null) {
  const dataset = document.querySelector('.comment-modal').dataset;
  return {
    content_id: dataset.contentId,
    current_user_id: dataset.currentUserId,
    parent_id: parentId,
    url: dataset.url,
    buttons: JSON.parse(dataset.formButtons)
  };
}

document.addEventListener('DOMContentLoaded', () => {
  if (document.querySelector('.show-comments-button') == null) return;

  const target = document.querySelector('.comment-modal');

  const event = () => {
    ReactDOM.render(
      <CommentBase showResolved={target.dataset.showResolved} button={target.dataset.commentText} />,
      document.querySelector('.comment-modal-body')
    )

    fetch(target.dataset.url, {
      mode: 'cors',
      credentials: 'include'
    }).then((response) => {
      return response.json();
    }).then((json) => {
      ReactDOM.render(
        <CommentIndex data={json} buttons={JSON.parse(target.dataset.buttons)} />,
        document.querySelector('.comment-index')
      );
      changeResolvedComment();
    });
  }

  ReactDOM.render(
    <Modal title={target.dataset.title} selector={document.querySelector('.show-comments-button')}
           className='comment-modal-body' event={event} />,
    target
  );
});
