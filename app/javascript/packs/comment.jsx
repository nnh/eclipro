import React from 'react'
import ReactDOM from 'react-dom'

class CommentIndex extends React.Component {
  render() {
    let body = [];

    this.props.data.map((data) => {
      body.push(
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
            {data.reply_url.length > 0 ? <ReplyButton url={data.reply_url} parentId={data.id} text={this.props.buttons[0]} /> : null}
            {data.resolve_url.length > 0 ? <ResolveButton url={data.resolve_url} text={this.props.buttons[1]} /> : null}
          </div>
          <div className='ml-xl'>
            {data.replies.length > 0 ? <CommentIndex data={data.replies} buttons={this.props.buttons} /> : null}
          </div>
          <div className='reply-form' id={`reply-${data.id}`}></div>
        </div>
      );
    });

    return (
      <div>{body}</div>
    );
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
            {this.props.buttons[0]}
          </button>
          <button className='btn btn-default ml-s' onClick={(e) => { this.onCancel(e) }}>{this.props.buttons[1]}</button>
        </div>
      </div>
    );
  }

  onSubmit(e) {
    $.ajax({
      url: $(e.target).data('url'),
      type: 'POST',
      dataType: 'json',
      data: {
        comment: {
          body: $(e.target).parent().siblings().val(),
          content_id: $(e.target).data('content-id'),
          user_id: $(e.target).data('user-id'),
          parent_id: $(e.target).data('parent-id')
        }
      }
    }).done((res) => {
      $(`#section-${res.no}-comment-icon`).html('<i class="fa fa-commenting mr-s">');
      $('.show-comments-button').html(`${$('.show-comments-button').data('text')} (${res.count})`);
      $('.show-comments-button').removeClass().addClass('btn btn-primary show-comments-button');
      ReactDOM.render(
        <CommentIndex data={res.comments} buttons={$('.comment-index').data('buttons')} />,
        $('.comment-index')[0]
      );
      resetForm();
      changeResolvedComment();
    });
  }

  onCancel(e) {
    resetForm();
  }

  onKeyUp(e) {
    this.setState({ text: $(e.target).val() });
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
    $.ajax({
      url: $(e.target).data('url'),
      type: 'PUT',
      dataType: 'json',
      data: {
        comment: {
          resolve: true
        }
      }
    }).done((res) => {
      ReactDOM.render(
        <CommentIndex data={res} buttons={$('.comment-index').data('buttons')} />,
        $('.comment-index')[0]
      );
      resetForm();
      changeResolvedComment();
    });
  }
}

class ReplyButton extends React.Component {
  render() {
    return (
      <button className='btn btn-default' onClick={(e) => { this.onClick(e) }}
              data-url={this.props.url} data-parent-id={this.props.parentId}>
        {this.props.text}
      </button>
    );
  }

  onClick(e) {
    $.ajax({
      url: $(e.target).data('url'),
      type: 'GET',
      dataType: 'json',
      data: {
        comment: {
          parent_id: $(e.target).data('parent-id')
        }
      }
    }).done((res) => {
      resetForm();
      ReactDOM.render(
        <CommentForm data={res} buttons={$('.new-comment-form').data('buttons')} />,
        $(`#reply-${res.parent_id}`)[0]
      );
    });
  }
}

function resetForm() {
  $('.reply-form, .new-comment-form').each((i, element) => { ReactDOM.unmountComponentAtNode(element); });
  $('.new-comment-form').hide();
  $('.add-comment-form').show();
}

function changeResolvedComment() {
  if ($('.show-resolved').is(':checked')) {
    $('.resolve-comment').show();
    $('.checkbox-text').text($('.resolve-message-params').data('hide-text'));
  } else {
    $('.resolve-comment').hide();
    $('.checkbox-text').text($('.resolve-message-params').data('show-text'));
  }
}

$(() => {
  $('.show-comments-button').click((e) => {
    $.ajax({
      url: $(e.target).data('url'),
      type: 'GET',
      dataType: 'json'
    }).done((res) => {
      ReactDOM.render(
        <CommentIndex data={res} buttons={$('.comment-index').data('buttons')} />,
        $('.comment-index')[0]
      );

      $('.comment-modal').modal('show');
      changeResolvedComment();
    });
  });

  $(document).on('click', '.add-comment-button', () => {
    resetForm();

    let target = $('.new-comment-form');
    let data = {
      content_id: target.data('content-id'),
      current_user_id: target.data('current-user-id'),
      parent_id: null,
      url: target.data('url')
    };
    ReactDOM.render(
      <CommentForm data={data} buttons={target.data('buttons')} />,
      $('.new-comment-form')[0]
    );

    $('.add-comment-form').hide();
    $('.new-comment-form').show();
  });

  $(document).on('change', '.show-resolved', changeResolvedComment);
});
