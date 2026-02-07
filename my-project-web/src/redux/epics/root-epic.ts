import { combineEpics } from 'redux-observable';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

// Example epic
const initEpic = (action$: Observable<any>) =>
  action$.pipe(
    map((action) => {
      if (action.type === 'APP_INIT') {
        console.log('App initialized');
      }
      return action;
    })
  );

export const rootEpic = combineEpics(initEpic);
