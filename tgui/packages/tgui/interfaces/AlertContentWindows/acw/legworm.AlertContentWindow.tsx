/**
 * @file
 * @copyright 2024
 * @author garash2k
 * @license ISC
 */
import { AlertContentWindow } from '../types';

const LegwormContentWindow = () => {
  return (
    <div className="traitor-tips">
      <h1 className="center">
        You have reawakened to serve your host changeling!
      </h1>
      <p>
        You must <em>obey</em> their commands!
        <br />
        You are a small creature that deliver powerful kicks and fit into tight
        spaces. You are still connected to the hivemind.
      </p>
      <p>
        Abilities
        <span className="small indent">
          <em>Power Kick</em> a human or an object to slam and send it flying.
          May also allow you to force open a door or smash tables and grilles.
          <br />
          <em>Writhe</em> on the floor to deal damage to and stun all
          surrounding creatures.
          <br />
          <em>Blood Boil</em> to generate intense heat using all of your
          remaining energy and explode, scalding nearby targets.
          <br />
          <em>Return to your Master</em> by clicking on them as you stand
          nearby. This will restore the DNA points that they spent to create
          you.
          <br />
        </span>
      </p>
    </div>
  );
};

export const acw: AlertContentWindow = {
  title: 'LegWorm Expectations',
  component: LegwormContentWindow,
};
