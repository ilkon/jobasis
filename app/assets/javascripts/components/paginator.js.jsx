function Paginator(props) {
  const neighbors = 2;
  const { current, total } = props;

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

  return <div>
    {
      firstSpot.length > 0 &&
      firstSpot.map((p) => <a>{p}</a> )
    }
    {
      firstSpot.length > 0 && currSpot.length > 0 && firstSpot[firstSpot.length - 1] === currSpot[0] - 2 &&
      <a>{currSpot[0] - 1}</a>
    }
    {
      firstSpot.length > 0 && currSpot.length > 0 && firstSpot[firstSpot.length - 1] < currSpot[0] - 2 &&
      '...'
    }
    {
      currSpot.length > 0 &&
      currSpot.map((p) => p === current ? <b>{p}</b> : <a>{p}</a> )
    }
    {
      currSpot.length > 0 && currSpot[currSpot.length - 1] === total - 1 &&
      <a>{total}</a>
    }
    {
      currSpot.length > 0 && currSpot[currSpot.length - 1] < total - 1 &&
      '...'
    }
  </div>;
}
