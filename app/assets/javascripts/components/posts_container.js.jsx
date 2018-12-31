class PostsContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = props;

    this.handlePageChange = this.handlePageChange.bind(this);
  }

  handlePageChange(page) {
    this.setState(prevState => ({
      paginator: { ...prevState.paginator, current: page }
    }));

    let url = new URL(window.location.href);
    url.search.set('page', page);

    fetch(url, {
      cache: 'no-cache',
      credentials: 'same-origin',
      headers: {
        'content-type': 'application/json'
      },
      method: 'GET',
      mode: 'cors',
      redirect: 'follow',
      referrer: 'no-referrer',
    })
        .then(response => {
          if (response.ok) {
            response.json().then(data => {
              this.setState({
                loading: false,
                info: data.data
              });
              if (data.data.top_tracks.length > 0) {
                this.props.handleArtistChange(data.data.name, data.data.top_tracks[0].name);
              }
            }).then(() => {
              window.scrollTo({
                top: 260,
                left: 0,
                behavior: 'smooth'
              });
            });
          } else {
            response.json().then(data => {
              this.setState({
                loading: false,
                errors: data.errors
              });
            });
          }
        });
  }

  render() {
    const { posts, paginator } = this.state;

    const postItems = posts.map((post) =>
        <PostItem key={post.id}
            post={post} />
    );

    return (
        <div>
          {
            postItems.length > 0 &&
            <ul>
              {postItems}
            </ul>
          }
          {
            postItems.length > 0 &&
            <Paginator current={paginator.current} total={paginator.total} handlePageChange={this.handlePageChange} />
          }
        </div>
    );
  }
}
