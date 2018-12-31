class Paginator extends React.Component {
  constructor(props) {
    super(props);

    this.handleClick = this.handleClick.bind(this);
  }

  handleClick(e) {
    this.props.handlePageChange(Number(e.target.id));
  }

  render() {
    const neighbors = 2;
    const { current, total } = this.props;

    // =1= 2  3 ...
    //  1 =2= 3  4 ...
    //  1  2 =3= 4  5 ...
    //  1  2  3 =4= 5  6 ...
    //  1  2  3  4 =5= 6  7 ...
    //  1  2  3  4  5 =6= 7  8 ...
    //  1  2  ...   5  6 =7= 8  9 ...
    //  ...
    //  1  2  ...  128  129 =130= 131  132 ...
    //  1  2  ...       129  130 =131= 132  133  134
    //  1  2  ...            130  131 =132= 133  134
    //  1  2  ...                 131  132 =133= 134
    //  1  2  ...                      132  133 =134=

    if (total === 0) {
      return null;
    }

    const spot = new Array(2 * neighbors + 1);
    const currSpot = Array.from(spot, (x, i) => i + current - neighbors).filter(i => i > 0 && i <= total);
    const firstSpot = Array.from(spot, (x, i) => i - neighbors).filter(i => !currSpot.includes(i) && i > 0 && i <= total);

    return (
        <ul className="paginator">
          {
            firstSpot.length > 0 &&
            firstSpot.map((p) => <li className="active" onClick={this.handleClick} key={p} id={p}>{p}</li>)
          }
          {
            firstSpot.length > 0 && currSpot.length > 0 && firstSpot[firstSpot.length - 1] === currSpot[0] - 2 &&
            <li className="active" onClick={this.handleClick} key={currSpot[0] - 1} id={currSpot[0] - 1}>{currSpot[0] - 1}</li>
          }
          {
            firstSpot.length > 0 && currSpot.length > 0 && firstSpot[firstSpot.length - 1] < currSpot[0] - 2 &&
            <li key={0}>...</li>
          }
          {
            currSpot.length > 0 &&
            currSpot.map((p) => p === current ? <li className="current" key={p}>{p}</li> : <li className="active" onClick={this.handleClick} key={p} id={p}>{p}</li>)
          }
          {
            currSpot.length > 0 && currSpot[currSpot.length - 1] === total - 1 &&
            <li className="active" onClick={this.handleClick} key={total} id={total}>{total}</li>
          }
          {
            currSpot.length > 0 && currSpot[currSpot.length - 1] < total - 1 &&
            <li key={-1}>...</li>
          }
        </ul>
    );
  }
}
